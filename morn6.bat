echo This batch file is in OneDrive

pushd %cd%

copy %cd%\data\stocks.csv c:\ruby\portmy\db\
copy %cd%\data\consensus.csv c:\ruby\portmy\db\

cd\Ruby\Portmy

echo The last statement does not execute.

popd