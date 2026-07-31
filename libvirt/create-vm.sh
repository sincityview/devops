#!/bin/bash
set -e

# Функция отображения помощи
show_help() {
    cat << EOF
Использование: create-vm -d <domain> -r <ram_mb> -c <vcpus> -s <disk_gb> -i <iso_path> -n <network>

Обязательные параметры:
  -d, --domain NAME       Имя виртуальной машины (домена)
  -r, --ram RAM_MB        Объем RAM в МБ
  -c, --vcpus VCPUS       Количество vCPUs
  -s, --disk-size GB      Размер диска в ГБ
  -i, --iso PATH          Путь к ISO образу
  -n, --network NETWORK   Имя сети libvirt

Опциональные параметры:
  -h, --help              Показать эту справку

Примеры:
  create-vm -d debian-test -r 4096 -c 2 -s 20 -i /var/lib/libvirt/iso/debian-13.6.0-amd64-netinst.iso -n vlan5-net
  create-vm --domain debian-test --ram 4096 --vcpus 2 --disk-size 30 --iso /custom/iso/debian.iso --network default
EOF
}

# Инициализация переменных
VM_NAME=""
VM_RAM=""
VM_VCPUS=""
DISK_SIZE_GB=""
ISO_PATH=""
NETWORK=""

# Парсинг аргументов командной строки
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--domain)
            VM_NAME="$2"
            shift 2
            ;;
        -r|--ram)
            VM_RAM="$2"
            shift 2
            ;;
        -c|--vcpus)
            VM_VCPUS="$2"
            shift 2
            ;;
        -s|--disk-size)
            DISK_SIZE_GB="$2"
            shift 2
            ;;
        -i|--iso)
            ISO_PATH="$2"
            shift 2
            ;;
        -n|--network)
            NETWORK="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Ошибка: Неизвестный параметр: $1"
            echo "Используйте -h или --help для справки."
            exit 1
            ;;
    esac
done

# Проверка обязательных параметров
if [ -z "$VM_NAME" ]; then
    echo "Ошибка: Не указано имя домена (-d или --domain)"
    exit 1
fi

if [ -z "$VM_RAM" ]; then
    echo "Ошибка: Не указан объем RAM (-r или --ram)"
    exit 1
fi

if [ -z "$VM_VCPUS" ]; then
    echo "Ошибка: Не указано количество vCPUs (-c или --vcpus)"
    exit 1
fi

if [ -z "$DISK_SIZE_GB" ]; then
    echo "Ошибка: Не указан размер диска (-s или --disk-size)"
    exit 1
fi

if [ -z "$ISO_PATH" ]; then
    echo "Ошибка: Не указан путь к ISO образу (-i или --iso)"
    exit 1
fi

if [ -z "$NETWORK" ]; then
    echo "Ошибка: Не указано имя сети (-n или --network)"
    exit 1
fi

# Проверка, что размер диска - положительное число
if ! [[ "$DISK_SIZE_GB" =~ ^[0-9]+$ ]] || [ "$DISK_SIZE_GB" -lt 1 ]; then
    echo "Ошибка: Размер диска должен быть положительным числом (в ГБ)"
    exit 1
fi

# Проверка, что RAM - положительное число
if ! [[ "$VM_RAM" =~ ^[0-9]+$ ]] || [ "$VM_RAM" -lt 512 ]; then
    echo "Ошибка: RAM должна быть положительным числом (в МБ, минимум 512)"
    exit 1
fi

# Проверка, что vCPUs - положительное число
if ! [[ "$VM_VCPUS" =~ ^[0-9]+$ ]] || [ "$VM_VCPUS" -lt 1 ]; then
    echo "Ошибка: Количество vCPUs должно быть положительным числом"
    exit 1
fi

# Проверка существования ISO файла
if [ ! -f "$ISO_PATH" ]; then
    echo "Ошибка: ISO файл не найден: $ISO_PATH"
    exit 1
fi

# Проверка существования сети
if ! sudo virsh net-list --all | grep -q "$NETWORK"; then
    echo "Ошибка: Сеть '$NETWORK' не найдена в libvirt"
    echo "Доступные сети:"
    sudo virsh net-list --all
    exit 1
fi

DISK_PATH="/var/lib/libvirt/images/${VM_NAME}.qcow2"

echo "=== Подготовка к созданию ВМ: ${VM_NAME} ==="
echo "  RAM: ${VM_RAM} МБ"
echo "  vCPUs: ${VM_VCPUS}"
echo "  Диск: ${DISK_SIZE_GB} ГБ"
echo "  Путь к диску: ${DISK_PATH}"
echo "  ISO: ${ISO_PATH}"
echo "  Сеть: ${NETWORK}"

# Проверяем существование старой ВМ или файла диска
if sudo virsh dominfo "${VM_NAME}" &>/dev/null || [ -f "${DISK_PATH}" ]; then
    echo ""
    echo "Внимание: ВМ с именем '${VM_NAME}' или её диск уже существуют."
    
    # Задаем вопрос пользователю
    read -p "Удалить старую ВМ и её данные перед установкой? [y/N]: " REPLY
    
    # Приводим ответ к нижнему регистру для надежности
    REPLY=$(echo "$REPLY" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$REPLY" == "y" || "$REPLY" == "yes" ]]; then
        echo "Удаляем старую конфигурацию и диск..."
        sudo virsh destroy "${VM_NAME}" &>/dev/null || true
        sudo virsh undefine "${VM_NAME}" --remove-all-storage &>/dev/null || true
        sudo rm -f "${DISK_PATH}"
        echo "Старая ВМ удалена."
        echo ""
    else
        echo "Отмена операции. Старая ВМ не изменена."
        exit 0
    fi
fi

echo "Запуск установки ОС..."

# Основная команда virt-install
sudo virt-install \
  --name "${VM_NAME}" \
  --ram "${VM_RAM}" \
  --vcpus "${VM_VCPUS}" \
  --disk path="${DISK_PATH}",size="${DISK_SIZE_GB}",format=qcow2,bus=virtio \
  --os-variant debian13 \
  --network network="${NETWORK}",model=virtio \
  --graphics none \
  --console pty,target_type=serial \
  --location "${ISO_PATH}" \
  --extra-args "console=ttyS0,115200n8" \
  --noautoconsole

# Проверяем статус создания
if [ $? -eq 0 ]; then
    echo ""
    echo "=== ВМ ${VM_NAME} успешно создана! ==="
    echo "Для подключения к текстовой консоли установщика выполните:"
    echo "sudo virsh console ${VM_NAME}"
    echo ""
    echo "Для проверки статуса ВМ:"
    echo "sudo virsh list --all"
    echo ""
    echo "Для получения IP адреса после установки:"
    echo "sudo virsh domifaddr ${VM_NAME}"
else
    echo "Ошибка: Не удалось создать ВМ"
    exit 1
fi
