#!/usr/bin/env python3
"""Lucky Blind Box 本地启动器（零第三方依赖，只用 Python 标准库）。

为什么不用 file:// 直接打开 index.html：
部分浏览器对 file:// 下的 localStorage / Canvas.toDataURL 有限制，
用本地 HTTP 服务能保证抽卡记录、加菜、分享卡片全部功能正常。
数据仍然只存在用户本机浏览器，不上传任何服务器。
"""
import http.server
import socketserver
import webbrowser
import threading
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
URL = f"http://127.0.0.1:{PORT}/"


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    """静默版静态文件处理器，只打印错误，避免刷屏。"""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def log_message(self, fmt, *args):
        # 只在出错时输出，正常访问不刷屏
        if args and str(args[1]).startswith(("4", "5")):
            super().log_message(fmt, *args)


class ReusableTCPServer(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True


def main():
    try:
        httpd = ReusableTCPServer(("127.0.0.1", PORT), QuietHandler)
    except OSError as exc:
        print(f"端口 {PORT} 启动失败：{exc}")
        print("可能该端口被占用，请关闭占用程序后重试，或传入其他端口。")
        sys.exit(1)

    print("=" * 46)
    print("  Lucky Blind Box · 干饭盲盒 已启动")
    print(f"  打开地址：{URL}")
    print("  关闭方式：在此窗口按 Ctrl+C（Mac 用 Control+C）")
    print("=" * 46)

    # 延迟一点再开浏览器，确保服务已经就绪
    threading.Timer(0.8, lambda: webbrowser.open(URL)).start()
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n已关闭，祝你好好干饭！")
        httpd.shutdown()


if __name__ == "__main__":
    main()
