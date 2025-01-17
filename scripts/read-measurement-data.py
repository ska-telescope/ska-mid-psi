# Requires the usage of the python-casacore library and the tabulate library
from casacore import tables
import tabulate
import sys
import numpy

numpy.set_printoptions(linewidth=2000)

obstable = tables.table(sys.argv[1])
max_row = int(input("Enter number of rows to retrieve:"))
phase = 0
if "DATA" in sys.argv:
    phase = int(input("Enter data phase to get:"))
columns_to_use = []
columns_with_desc = []
display_table = []
if len(sys.argv) < 3:
    print("Possible columns to use")
    cols = obstable.colnames()
    print(cols)
    user_data = input("Enter comma separated list of columns to use:")
    columns_to_use = user_data.split(", ")

else:
    columns_to_use = sys.argv[2:]

for i in range(0,max_row):
    row = []
    for column in columns_to_use:
        if column == 'TIME':
            clean_time = "..."
            clean_time += str(obstable.getcol(column,i,i+1)[0])[-20:]
            row.append(clean_time)
        elif column == 'DATA':
            row.append(((obstable.getcol(column,i,i+1)[0]))[0,0])
        else:
            row.append(obstable.getcol(column,i,i+1)[0])
    display_table.append(row)
print("--------------------------------")
for column in columns_to_use:
    desc = column + ": "+ obstable.getcoldesc(column)['comment']
    print(desc)
print("--------------------------------\n")

print(tabulate.tabulate(display_table,headers=columns_to_use, tablefmt="outline"))

print("Done!")
