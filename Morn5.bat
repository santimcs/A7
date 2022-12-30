echo This batch file is in OneDrive

copy %cd%\data\stocks.csv c:\ruby\portmy\db\
copy %cd%\data\consensus.csv c:\ruby\portmy\db\

cd \ruby\portmy
rails runner db\crt_all.rb

