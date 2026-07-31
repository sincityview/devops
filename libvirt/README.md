###### create-vm.sh

> Использование: create-vm -d <domain> -r <ram_mb> -c <vcpus> -s <disk_gb> -i <iso_path> -n <network>

**Обязательные параметры:**
 - -d, --domain NAME       Имя виртуальной машины (домена)
 - -r, --ram RAM_MB        Объем RAM в МБ
 - -c, --vcpus VCPUS       Количество vCPUs
 - -s, --disk-size GB      Размер диска в ГБ
 - -i, --iso PATH          Путь к ISO образу
 - -n, --network NETWORK   Имя сети libvirt

**Опции:**
 - -h, --help              Показать эту справку

**Примеры:**
```
create-vm --domain debian-test --ram 4096 --vcpus 2 --disk-size 30 --iso /custom/iso/debian.iso --network default
```

<br>

###### destroy-vm.sh

> Использование: destroy-vm <domain>

**Удаляет виртуальную машину и все связанные с ней ресурсы:**
 - Останавливает ВМ (если запущена)
 - Удаляет определение ВМ из libvirt
 - Удаляет файл диска (.qcow2)
 - Удаляет связанные тома и снапшоты (опционально)

**Параметры:**
 - <domain>    Имя виртуальной машины (домена) для удаления

**Опции:**
 - -f, --force    Принудительное удаление без подтверждения
 - -h, --help     Показать эту справку

**Примеры:**
```
destroy-vm debian-test
destroy-vm --force debian-test
```
