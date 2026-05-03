#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Папка с proto-файлами внутри репозитория
PROTO_SUBDIR="proto"
PROTO_ABS_PATH="$SCRIPT_DIR/$PROTO_SUBDIR"

if [ ! -d "$PROTO_ABS_PATH" ]; then
    echo "Ошибка: папка '$PROTO_SUBDIR' не найдена в $SCRIPT_DIR"
    exit 1
fi

echo "Проверка прото-файлов в $PROTO_ABS_PATH"

if ! command -v docker &> /dev/null; then
    echo "Ошибка: Docker не установлен"
    exit 1
fi

# Монтируем корень репозитория в /work
# Ищем все .proto внутри /work/proto, передаём пути относительно /work (например, proto/common/file.proto)
# protoc видит импорты вида "proto/..." и правильно их разрешает относительно --proto_path=/work
docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "$SCRIPT_DIR:/work" \
    -w /work \
    --entrypoint sh \
    jaegertracing/protobuf:latest \
    -c 'find proto -name "*.proto" -print0 | xargs -0 protoc --proto_path=/work --descriptor_set_out=/dev/null'

echo "✅ Все .proto файлы синтаксически корректны."