#!/bin/bash
# Lucky Blind Box（干饭盲盒）macOS 启动器
# 双击本文件即可启动。纯静态应用，无需安装依赖、无需 API key。
# 数据保存在浏览器本地，不上传任何服务器。
cd "$(dirname "$0")" || { echo "无法进入项目目录"; exit 1; }

PORT=8765
URL="http://127.0.0.1:$PORT/"

# 找 Python（优先 python3）
PY=""
for c in python3 python; do
  if command -v "$c" >/dev/null 2>&1; then PY="$c"; break; fi
done
if [ -z "$PY" ]; then
  echo "未找到 Python。本应用需要 Python 3（macOS 通常自带）。"
  echo "若无，请到 python.org 安装后重试。"
  read -n 1 -s -r -p "按任意键退出"; exit 1
fi

# 端口被占：只清本项目的服务（命令行含 serve.py + 本项目名），绝不误杀别的程序
if lsof -nP -iTCP:$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
  for pid in $(lsof -nP -iTCP:$PORT -sTCP:LISTEN -t 2>/dev/null); do
    cmd=$(ps -p "$pid" -o command= 2>/dev/null)
    case "$cmd" in
      *serve.py*|*lucky-blindbox*|*盲盒*)
        echo "关闭旧的盲盒服务（PID $pid）…"
        kill "$pid" 2>/dev/null ;;
      *)
        echo "端口 $PORT 被其他程序占用（PID $pid），为避免误杀已停止。"
        echo "请关闭该程序后重试，或联系我们获取自定义端口版本。"
        read -n 1 -s -r -p "按任意键退出"; exit 1 ;;
    esac
  done
  for _ in $(seq 1 50); do
    lsof -nP -iTCP:$PORT -sTCP:LISTEN -t >/dev/null 2>&1 || break
    sleep 0.1
  done
fi

echo "正在启动干饭盲盒…"
exec "$PY" serve.py "$PORT"
