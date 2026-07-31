#!/bin/bash
set -e

# Функция отображения помощи
show_help() {
    cat << EOF
Использование: destroy-vm <domain>

Описание:
  Удаляет виртуальную машину и все связанные с ней ресурсы:
  - Останавливает ВМ (если запущена)
  - Удаляет определение ВМ из libvirt
  - Удаляет файл диска (.qcow2)
  - Удаляет связанные тома и снапшоты (опционально)

Параметры:
  <domain>    Имя виртуальной машины (домена) для удаления

Опции:
  -f, --force    Принудительное удаление без подтверждения
  -h, --help     Показать эту справку

Примеры:
  destroy-vm debian-test
  destroy-vm --force debian-test
EOF
}

# Инициализация переменных
FORCE=false
VM_NAME=""

# Парсинг аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            VM_NAME="$1"
            shift
            ;;
    esac
done

# Проверка обязательных параметров
if [ -z "$VM_NAME" ]; then
    echo "Ошибка: Не указано имя домена"
    echo "Используйте -h или --help для справки."
    exit 1
fi

DISK_PATH="/var/lib/libvirt/images/${VM_NAME}.qcow2"

# Проверяем, существует ли ВМ или диск
if ! sudo virsh dominfo "${VM_NAME}" &>/dev/null && [ ! -f "${DISK_PATH}" ]; then
    echo "Ошибка: ВМ '${VM_NAME}' или её диск не найдены"
    echo ""
    echo "Существующие ВМ:"
    sudo virsh list --all
    exit 1
fi

# Вывод информации о ВМ
echo "=== Удаление ВМ: ${VM_NAME} ==="

if sudo virsh dominfo "${VM_NAME}" &>/dev/null; then
    VM_STATE=$(sudo virsh dominfo "${VM_NAME}" | grep "State" | awk '{print $2}')
    echo "  Состояние: ${VM_STATE}"
fi

if [ -f "${DISK_PATH}" ]; then
    DISK_SIZE=$(du -h "${DISK_PATH}" | cut -f1)
    echo "  Диск: ${DISK_PATH} (${DISK_SIZE})"
fi

# Запрос подтверждения (если не используется --force)
if [ "$FORCE" = false ]; then
    echo ""
    read -p "Вы уверены, что хотите удалить ВМ '${VM_NAME}' и все её данные? [y/N]: " REPLY
    REPLY=$(echo "$REPLY" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$REPLY" != "y" && "$REPLY" != "yes" ]]; then
        echo "Операция отменена."
        exit 0
    fi
fi

echo ""
echo "Удаление ВМ..."

# 1. Останавливаем ВМ
if sudo virsh dominfo "${VM_NAME}" &>/dev/null; then
    echo "  - Остановка ВМ..."
    sudo virsh destroy "${VM_NAME}" &>/dev/null || {
        echo "    (ВМ уже остановлена или не запущена)"
    }
    
    # 2. Удаляем определение ВМ
    echo "  - Удаление определения ВМ из libvirt..."
    sudo virsh undefine "${VM_NAME}" --remove-all-storage &>/dev/null || {
        echo "    (Не удалось удалить через virsh undefine, пробуем другие методы...)"
    }
fi

# 3. Принудительно удаляем файл диска (на случай, если он остался)
if [ -f "${DISK_PATH}" ]; then
    echo "  - Удаление файла диска..."
    sudo rm -f "${DISK_PATH}"
    echo "    Файл диска удален: ${DISK_PATH}"
fi

# 4. Проверяем наличие связанных томов в пуле и удаляем их (опционально)
# Это может быть полезно, если использовались дополнительные тома
echo "  - Проверка связанных томов в пуле 'images'..."
if sudo virsh vol-list images 2>/dev/null | grep -q "${VM_NAME}"; then
    echo "    Найдены связанные тома, удаляем..."
    sudo virsh vol-list images | grep "${VM_NAME}" | awk '{print $1}' | while read -r vol; do
        if [ -n "$vol" ]; then
            echo "    Удаление тома: $vol"
            sudo virsh vol-delete --pool images "$vol" 2>/dev/null || true
        fi
    done
fi

echo ""
echo "=== ВМ ${VM_NAME} успешно удалена! ==="
echo ""
echo "Текущие ВМ:"
sudo virsh list --all
