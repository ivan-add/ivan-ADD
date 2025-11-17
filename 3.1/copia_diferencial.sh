#!/bin/bash
#Creamos las copias diferenciales le damos la variable de semana
semana=$(date +%U)
tar -g /bacivandestino/snapshot.snar -czf /bacivandestino/CopDifSem-$semana.tar.gz /home/
