// pane-title-sync: 把 omp 会话名(小模型摘要的主题)同步为 herdr pane 标签,
// 让 prefix+s Navigator 和 pane 列表显示 "tmux与herdr设计理念区别" 而不是 "pane 1"。
// 独立扩展, 不在 herdr integration 管理范围; 删除本文件即完全回退。
// 触发: session_start / session_switch / turn_end / agent_end + 延迟重试
// (标题由 tiny 模型在首轮后异步生成, 单次同步可能取到旧值)。
// 注意: 同步的是 manual label, prefix+. 手动重命名会在下一次触发时被覆盖。
import net from "node:net";

const paneId = process.env.HERDR_PANE_ID;
const socketPath = process.env.HERDR_SOCKET_PATH;
const enabled =
  process.env.HERDR_ENV === "1" && !!socketPath && !!paneId && !!process.stdout.isTTY;

interface ExtensionApi {
  on(event: string, handler: (event: unknown, ctx: unknown) => void): void;
}

interface SyncContext {
  sessionManager?: { getSessionName?: () => unknown };
}

function isSyncContext(ctx: unknown): ctx is SyncContext {
  if (!ctx || typeof ctx !== "object" || !("sessionManager" in ctx)) return false;
  const manager = (ctx as { sessionManager: unknown }).sessionManager;
  return (
    !!manager &&
    typeof manager === "object" &&
    typeof (manager as { getSessionName?: unknown }).getSessionName === "function"
  );
}

let lastLabel = "";
let queue: Promise<void> = Promise.resolve();

function renamePane(label: string): Promise<void> {
  const clean = label.trim();
  if (!clean || clean === lastLabel) return Promise.resolve();
  lastLabel = clean;
  const { promise, resolve } = Promise.withResolvers<void>();
  const socket = net.createConnection(socketPath!);
  let done = false;
  const finish = () => {
    if (done) return;
    done = true;
    socket.destroy();
    resolve();
  };
  socket.setTimeout(500);
  socket.on("connect", () => {
    socket.write(
      `${JSON.stringify({
        id: `pane-title-sync:${Date.now()}`,
        method: "pane.rename",
        params: { pane_id: paneId, label: clean },
      })}\n`,
    );
  });
  socket.on("data", finish);
  socket.on("error", finish);
  socket.on("timeout", finish);
  socket.on("end", finish);
  return promise;
}

export default function (pi: ExtensionApi): void {
  if (!enabled) return;
  const sync = (ctx: unknown) => {
    if (!isSyncContext(ctx)) return;
    const raw = ctx.sessionManager?.getSessionName?.();
    if (typeof raw !== "string") return;
    const clean = raw.trim();
    if (!clean || clean === lastLabel) return;
    queue = queue.then(() => renamePane(clean));
    // 标题由 tiny 模型在首轮后异步生成, 延迟补抓两次兜底
    for (const delay of [2000, 6000]) {
      const timer = setTimeout(() => void renamePane(clean), delay);
      timer.unref?.();
    }
  };
  pi.on("session_start", (_event, ctx) => sync(ctx));
  pi.on("session_switch", (_event, ctx) => sync(ctx));
  pi.on("turn_end", (_event, ctx) => sync(ctx));
  pi.on("agent_end", (_event, ctx) => sync(ctx));
}
