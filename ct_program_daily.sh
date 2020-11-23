#!/bin/bash -x

# Set this script in cron with crontab -e
# 0 3 * * * /home/USERNAME/MyCrons/ct_program_daily.sh

# Set date parameter and destination folder for program file
BASE=`pwd`
OUT_DATE=$( date +"%Y%m%d" )
LOG_DIR="/log"
LOGFILE="$BASE/$LOG_DIR/$OUT_DATE.log"
CURR_DATE=$( date +"%d.%m.%Y" )
IN_DIR="$BASE/downloaded"
OUT_DIR="$BASE/processed"

# bucket url https://console.cloud.google.com/storage/browser/BUCKETID
BUCKET="gs://BUCKETID"
BQ_DATA="BUCKETID.daily_import"
SCHEMA="$BASE/bq_full_schema.json"

# Create a new log file
echo "Script initiated on $CURR_DATE" by $USER > $LOGFILE

# Download xml program into folder - url pattern:
# https://www.ceskatelevize.cz/services-old/programme/xml/shedule.php?user=[login]&date=[dd.mm.rrrr]&channel=[ct1|ct2|ct24|ct4|ct5|ct6]

# program url without parameters
URL="https://www.ceskatelevize.cz/services-old/programme/xml/schedule.php?user=USERNAME"

# set date parameter for url
URL_DATE="&date="$( date +"%d.%m.%Y" )

# Download program for all channels
echo "# Starting download for $OUT_DATE"

# For each channel download daily program and convert into csv
for i in "ct1" "ct2" "ct24" "ct4" "ct5" "ct6"; do

    echo -en "\n" >> $LOGFILE
    echo -e "--$i--\n" >> $LOGFILE
    URL_CHANNEL="&channel=$i"
    URL_SET=$URL$URL_DATE$URL_CHANNEL
    
    # Save as output format "YYYYMMDD_channel.xml"
    XML_FILE=${OUT_DATE}_$i.xml
    CSV_FILE=${OUT_DATE}_$i.csv
    
    echo -e "# Downloading from $URL_SET \nas $IN_DIR/$XML_FILE" >> $LOGFILE
    wget $URL_SET --output-document=$IN_DIR/$XML_FILE >> $LOGFILE
    
    sleep 2
    echo -en "\n" >> $LOGFILE

    # Convert xml into csv
    echo -e "# Converting xml into csv \n$IN_DIR/$XML_FILE -> $OUT_DIR/$CSV_FILE" >> $LOGFILE
    xmlstarlet sel -t \
	       -m / -o "datum_vysilani;kanal;generovano;program;ivysilani;vps;cas;nadtitul;nazev;original;nazev_casti;dil;zanr;stopaz;noticka;regionalni;alternativa;zvuk;skryte_titulky;neslysici;live;premiera;cb;hvezdicka;puvodni_zneni;pomer;hd;tv_program" -n -b \
	       -m /program/porad \
	       -v ../@datum_vysilani -o ";"\
	       -v ../@kanal -o ";"\
	       -v ../@generovano -o ";"\
	       -v linky/program -o ";"\
	       -v linky/ivysilani -o ";"\
	       -v vps -o ";"\
	       -v cas -o ";" \
	       -v nazvy/nadtitul -o ";"\
	       -v nazvy/nazev -o ";"\
	       -v nazvy/original -o ";"\
	       -v nazvy/nazev_casti -o ";"\
	       -v dil -o ";"\
	       -v zanr -o ";"\
	       -v stopaz -o ";"\
	       -v noticka -o ";"\
	       -v regionalni -o ";"\
	       -v alternativa -o ";"\
	       -v ikonky/zvuk -o ";"\
	       -v ikonky/skryte_titulky -o ";"\
	       -v ikonky/neslysici -o ";"\
	       -v ikonky/live -o ";"\
	       -v ikonky/premiera -o ";"\
	       -v ikonky/cb -o ";"\
	       -v ikonky/hvezdicka -o ";"\
	       -v ikonky/puvodni_zneni -o ";"\
	       -v ikonky/pomer -o ";"\
	       -v ikonky/hd -o ";"\
	       -v obrazky/tv_program\
	       -n \
	       $IN_DIR/$XML_FILE > $OUT_DIR/$CSV_FILE

    sleep 2
    echo -en "\n" >> $LOGFILE

    # Upload to Google Storage
    echo -e "# Uploading $CSV_FILE to Google Storage\n\
Destination bucket $BUCKET/$CSV_FILE" >> $LOGFILE
    gsutil cp -n $OUT_DIR/$CSV_FILE $BUCKET >> $LOGFILE

    sleep 2
    echo -en "\n" >> $LOGFILE

    # Import files from Cloud Storage into BQ
    echo "# Submitting import $CSV_FILE from Google Storage to Big Query" >> $LOGFILE
    sleep 2
    
    # bq --location=[LOCATION] load --source_format=[FORMAT] [DATASET].[TABLE] [PATH_TO_SOURCE] [SCHEMA]
    echo "Destination table $BQ_DATA" >> $LOGFILE
    bq load \
       --source_format CSV \
       --encoding UTF-8 \
       --skip_leading_rows 1 \
       --field_delimiter ";" \
       #--max_bad_records 10 \
       $BQ_DATA $BUCKET/$CSV_FILE $SCHEMA

    sleep 2
    echo -en "\n" >> $LOGFILE
    
done

# Find the xml files with the date parameter in its name
echo -e "Downloaded xml files in $IN_DIR:\n\
$( find "$IN_DIR/" -type f -atime -1 -iname "$DATE_FILE*.xml" )" >> $LOGFILE

# Find the csv files with the date parameter
echo -en "Processed csv files in $OUT_DIR:\n\
$( find "$OUT_DIR/" -type f -atime -1 -iname "$DATE_FILE*.csv" )" >> $LOGFILE

# Find files in Google Storage
echo "Project id $( bq show )" >> $LOGFILE
echo -en "List buckets in Storage\n `gsutil ls`" >> $LOGFILE
echo -e "Uploaded csv files to Google Storage" >> $LOGFILE


exit 0
