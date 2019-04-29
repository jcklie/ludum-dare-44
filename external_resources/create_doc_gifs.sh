merge_frame() {
  montage ../player/skin/eur/idle/$1.png ../player/skin/usd/idle/$1.png ../player/skin/gbp/idle/$1.png ../player/skin/yen/idle/$1.png -tile 4x1 -geometry +0+0 out_merged_$1.png
}

convert_to_gif () {
  for i in `seq 0 15`;
  do
    merge_frame $i
  done

  convert -delay 15 -loop 0 -dispose 2 out_merged_{0..15}.png ../docs/currency_anim.gif
}

convert_to_gif
