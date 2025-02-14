#! /bin/bash

#Utility to clean up non-essential intermediate products during and following a large batch ASP run

#qsub -I -q devel -lselect=1:model=bro,walltime=2:00:00
#parallel --jobs 14 --delay 1 --verbose --progress 'ortho_proc.sh {}' ::: *_1*00
#Note: Only delete after DEM stage, if running, subsequent stereo steps will fail due to missing input files, even if L an R exist
#rm $(ls *00/1*_ortho_*m.{tif,xml} | grep -v 30m)

#Dry run
#rm="echo rm"
rm="rm"

#This isolates past the dg_mosaic stage - can delete ntf and corr
list=$(ls */*ortho*.tif | awk -F'/' '{print $1}' | sort -u)

for i in $list
do 
    echo $i
    $rm $i/*corr.{tif,xml}
    if [ ! -e $i/${i}_ntf_xml_list.txt ] ; then
        ls -AFlhp $i/*_P*.{ntf,xml} > $i/${i}_ntf_xml_list.txt
    fi
    $rm $i/*_P*.{ntf,xml}
    echo
done

list=$(ls */dem*/*-DEM_32m.tif | awk -F'/' '{print $1}' | sort -u)
for i in $list
do 
    echo $i
    $rm $i/dem*/*-{R,L}.tif
    $rm $i/dem*/*-{D_sub,D,RD,F,PC,GoodPixelMap,lMask,lMask_sub,rMask,rMask_sub}.tif
    $rm $i/dem*/*.{txt,default,match}
    $rm $i/dem*/*.{dbf,prj,shp,shx}
    echo
done

#If nothing left in queue, tar up logs
u=deshean
if ! qstat -u $u | grep -q $u ; then
    #Tar up log 
    echo "Creating log.tar"
    tar_fn=log.tar
    tar -cf $tar_fn log 
    #$rm -r log
fi
