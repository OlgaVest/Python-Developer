#!/bin/bash

# Скрипт для автоматической настройки FastAPI проекта
# Автор: [Твое имя]
# Дата: $(date)

echo "=== Начинаем настройку FastAPI проекта ==="

# Проверка наличия Python 3
echo "Проверяем наличие Python 3..."
if ! command -v python3 &> /dev/null
then
    echo "❌ ОШИБКА: Python 3 не установлен!"
    echo "Пожалуйста, установите Python 3 и повторите попытку."
    exit 1
else
    echo "✅ Python 3 найден: $(python3 --version)"
fi

# Проверка наличия pip
echo "Проверяем наличие pip..."
if ! command -v pip3 &> /dev/null
then
    echo "⚠️  pip3 не найден. Попытка установки..."
    # Попытка установить pip
    sudo apt update
    sudo apt install python3-pip -y
else
    echo "✅ pip3 найден: $(pip3 --version)"
fi

# Создание директории для проекта
echo "Создаем директорию для проекта..."
PROJECT_DIR="fastapi_project"

# Проверяем, существует ли директория
if [ -d "$PROJECT_DIR" ]; then
    echo "⚠️  Директория $PROJECT_DIR уже существует!"
    read -p "Хотите очистить её? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Очищаем директорию $PROJECT_DIR..."
        rm -rf "$PROJECT_DIR"/*
        echo "✅ Директория очищена"
    else
        echo "❌ Операция отменена пользователем"
        exit 1
    fi
else
    echo "Создаем новую директорию $PROJECT_DIR..."
    mkdir "$PROJECT_DIR"
    echo "✅ Директория создана"
fi

# Переходим в директорию проекта
echo "Переходим в директорию проекта..."
cd "$PROJECT_DIR"
echo "Текущая директория: $(pwd)"

# Создание виртуального окружения
echo "Создаем виртуальное окружение..."
python3 -m venv venv
if [ $? -eq 0 ]; then
    echo "✅ Виртуальное окружение создано"
else
    echo "❌ Ошибка при создании виртуального окружения"
    exit 1
fi

# Активируем виртуальное окружение
echo "Активируем виртуальное окружение..."
source venv/bin/activate
if [ $? -eq 0 ]; then
    echo "✅ Виртуальное окружение активировано"
    echo "Текущий Python: $(which python)"
    echo "Текущий pip: $(which pip)"
else
    echo "❌ Ошибка при активации виртуального окружения"
    exit 1
fi

# Создание файла requirements.txt
echo "Создаем файл requirements.txt..."
cat > requirements.txt << EOF
fastapi
uvicorn[standard]
pydantic
EOF

if [ $? -eq 0 ]; then
    echo "✅ Файл requirements.txt создан"
    echo "Содержимое requirements.txt:"
    cat requirements.txt
else
    echo "❌ Ошибка при создании requirements.txt"
    exit 1
fi

# Установка зависимостей
echo "Устанавливаем зависимости из requirements.txt..."
pip install -r requirements.txt
if [ $? -eq 0 ]; then
    echo "✅ Зависимости установлены успешно"
    echo "Установленные пакеты:"
    pip list | grep -E "fastapi|uvicorn|pydantic"
else
    echo "❌ Ошибка при установке зависимостей"
    exit 1
fi

# Создание структуры директорий
echo "Создаем структуру директорий..."
mkdir -p static logs
if [ $? -eq 0 ]; then
    echo "✅ Директории static и logs созданы"
else
    echo "❌ Ошибка при создании директорий"
    exit 1
fi

# Создание файла main.py с минимальным приложением FastAPI
echo "Создаем файл main.py..."
cat > main.py << 'EOF'
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello, FastAPI!"}

@app.get("/health")
def health_check():
    return {"status": "healthy", "message": "FastAPI application is running"}
EOF

if [ $? -eq 0 ]; then
    echo "✅ Файл main.py создан"
    echo "Содержимое main.py:"
    cat main.py
else
    echo "❌ Ошибка при создании main.py"
    exit 1
fi

# Финальный шаг - запуск сервера
echo "=== ВСЕ ГОТОВО! ==="
echo "Проект успешно создан в директории: $(pwd)"
echo "Чтобы запустить сервер, выполните команду:"
echo "source venv/bin/activate && uvicorn main:app --reload"
echo "Затем откройте в браузере: http://127.0.0.1:8000"