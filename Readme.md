# Project for Prometheus and Loki
Папка этого проекта должна быть __prom-loki_blank__!
## Создание пользователя и группы:
### Автоматически:
Добавлено при запуске init0all.sh.

### Вручную:
1. Создайте пользователя формата __adduser --gecos "" TYPE__, где TYPE - это проект; 
2. Укажите соответствующий uid, командой __usermod -u 10XXZ TYPE__, XX - это № проекта, а где Z - это номер организации;
3. Исправьте gid группы __groupmod -g 10XXZ TYPE__;
4. Добавьте пользователя в группу проекта __usermod -aG TYPE TYPE__.

## Запустить загрузку и создание:
### Автоматически:
Запустить скрипт с переменной __$ORG__ - организации и __$MAIN_PROJECT__ главный проект grafan'ы (не обязательно), например:
```sh
bash init0all.sh avtocifra grafana
```
### Вручную:
1. Создать .env из .env_blank изменив группу, проект и организацию;
2. Запустить соответствующий скрипт проекту для загрузки , предварительно заменив внутри __Z__ - номер пользователя.

## Подключение экспортёров:
1. Добавить адреса и настройки экспортёров в файл __config/prometheus/prometheus.yml__