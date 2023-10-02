
#  Дипломная работа по профессии «Системный администратор - Прохоров Семен»

---------

### Сайт

Создал инфраструктуру из 6 ВМ.Согласно заданию. web-1 и web-2 помещены в разные зоны.Сервера Web,Elasticsearh помещены в приватные подсети.Сервера Zabbix, Kibana, application load balancer помещены в публичную подсеть.

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/1.PNG)

Установил NGINX на две ВМ

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/2.PNG)

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/3.PNG)

Создал [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/4.PNG)

Создал [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настроил backends на target group, ранее созданную. Настроил healthcheck на корень (/) и порт 80, протокол HTTP.

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/5.PNG)

Создал [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь указал — /, backend group — созданную ранее.

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/6.PNG)

Создал [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Указал HTTP router, созданный ранее, задал listener тип auto, порт 80.

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/7.PNG)

Протестировал сайт
`curl -v 158.160.125.74:80` 

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/8.PNG)

### Мониторинг
Создал ВМ, развернул на ней Zabbix. На каждую ВМ установил Zabbix Agent, настроил агенты на отправление метрик в Zabbix.

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/9.PNG)

Настрол дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам.

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/10.PNG)

http://84.201.147.51:8080/

### Логи
Cоздал ВМ, развернул на ней Elasticsearch. Установил filebeat в ВМ к веб-серверам, настроил на отправку access.log, error.log nginx в Elasticsearch.

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/11.PNG)

На web1 и web2 установлены filebeat.Заходим поочередно на сервера и настраиваем конфиг файл на отправку логов.

Подключаемся к web-1 и web-2 через bastion host и редактуриуем файл nginx.yml.disabled, заменяя false на true в блоках error и access

`sudo nano /etc/filebeat/modules.d/nginx.yml.disabled`

`sudo systemctl restart filebeat`

`sudo filebeat modules enable nginx`

`sudo filebeat setup`

`sudo filebeat -e`

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/12.PNG)

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/13.PNG)

Создал ВМ, развернул на ней Kibana, сконфигурировал соединение с Elasticsearch.

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/14.PNG)

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/15.PNG)

http://84.201.145.197:5601/

### Сеть
Развернул один VPC. Сервера web, Elasticsearch поместил в приватные подсети. Сервера Zabbix, Kibana, application load balancer определил в публичную подсеть.

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/16.PNG)

Настроил [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/17.PNG)

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/18.PNG)

Настроил ВМ с публичным адресом, в которой будет открыт только один порт — ssh. Настройте все security groups на разрешение входящего ssh из этой security group. Эта вм будет реализовывать концепцию bastion host. Потом можно будет подключаться по ssh ко всем хостам через этот хост.

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/19.PNG)

### Резервное копирование
Создал snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настроил на ежедневное копирование.

![alt text](https://github.com/colex29/sys-diplom/blob/9208f78160bcf2443782142388262700e2cae5b4/img/20.PNG)


