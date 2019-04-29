convert_to_gif () {
  convert -delay 15 -loop 0 -dispose 2 ../player/skin/$1/idle/{0..15}.png ../docs/anim-$1.gif
}

convert_to_gif "eur"
convert_to_gif "gbp"
convert_to_gif "usd"
convert_to_gif "yen"

