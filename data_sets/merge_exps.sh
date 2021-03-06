#!/usr/bin/env zsh
# vim: set et sts=4 sw=4 cc=80:
#
# merge_exps.sh: Take all those experiments, yeah? Now mush 'em together.
#
#               $1+: Folders the experiments are in.

dir="exp_merge/"
mkdir -p $dir

e="----"

IFS=$'\t\n\0'
for file in $1/*res_*; do
    #echo $file
    file_base=${${file#*/}%_2017*}
    out=$dir/$file_base
    rm $out
    for l in `grep -h "|Q|" $file`; do
        echo $l >> $out
        l=${l//|/\\|}
        for a in $@; do
            #echo -n "$a " >> $out
            awk "/$l/{f=1;next} /$e/{f=0} f" $a/${file_base}* >> $out
        done
        echo $e >> $out
    done
done
