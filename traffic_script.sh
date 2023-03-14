#!/bin/bash

#NR es una variable built-in. Es igual a 1 solo cuando se esta analizando la header line.
#Nos guarda el primer campo de cada linea a partir de la linea 2. Esto sirve para no incluir los 
#campos de la header line. Obtenemos el nombre del grupo.
GROUP_NAME=$(gcloud compute instance-groups managed list | awk '{ if (NR!=1) print $1}')

#Como que las istancias son efimeras el script calcula automaticamente cada vez que se ejecuta la IP interna de#la istancia principal del grupo. Si quisiesemos la IP externa tendriamos que usar "networkInterfaces[0].access#Configs[0].natIP". Obtenemos una lista de todas las istancias que empiezan por "my-instance-group" con 3 
#campos: nombre, IP y creationTimestamp. Despues ordenamos la lista por el campo 3 cronologicamente, con la
#instancia más antigua apareciendo primero en la lista.
INSTANCE_LIST=$(gcloud compute instances list --format='value(name,networkInterfaces[0].networkIP,creationTimestamp)' | grep $GROUP_NAME* | sort -k3)

#En el caso de que tengamos más de una instancia en la lista, solo extraemos el segundo campo (IP interna) 
#de la primera linea (primera linea= istancia principal del grupo).
MAIN_INSTANCE_IP=$(echo $INSTANCE_LIST | head -n 1 | awk '{print $2}')

#Número de solicitudes a realizar.
REQUESTS=1000

#Numero de solicitudes simultaneas.
CONCURRENCY=10

#Usamos el comando "ab"(Apache Benchmark) para enviar 1000 solicitudes y cada una de ellas se enviará
#simultáneamente con 10 solicitudes adicionales. Significa que se enviarán 1000*10 = 10000 solicitudes HTTP.
ab -n $REQUESTS -c $CONCURRENCY "http://$MAIN_INSTANCE_IP/"  > /dev/null



#OTRO EJEMPLO UTILIZANDO EL COMANDO PING

#GROUP_NAME=$(gcloud compute instance-groups managed list | awk '{ if (NR!=1) print $1}')
#INSTANCE_LIST=$(gcloud compute instances list --format='value(name,networkInterfaces[0].networkIP,creationTime#stamp)' | grep $GROUP_NAME* | sort -k3)

#MAIN_INSTANCE_IP=$(echo $INSTANCE_LIST | head -n 1 | awk '{print $2}')

#REQUESTS=1000

#for i in $(seq 1 $REQUESTS); do
 #ping -c 1 $MAIN_INSTANCE_IP > /dev/null
#done