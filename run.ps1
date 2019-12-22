param(
    $lat,
    $lng
)
echo $lat
echo $lng

conda activate cityenv
python main.py "$lat" "$lng"
