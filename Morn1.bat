echo %cd%

ruby ruby\crt-consensus-fm-iaa.rb

ruby ruby\crt-stocks-fm-fs.rb

copy %cd%\data\stocks.csv c:\ruby\portpg\db\
copy %cd%\data\consensus.csv c:\ruby\portpg\db\

cd \ruby\portpg

rails runner db\crt_all.rb

echo %cd%