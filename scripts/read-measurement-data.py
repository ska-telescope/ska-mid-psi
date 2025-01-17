# Requires the usage of the python-casacore library and the tabulate library
from casacore import tables
import tabulate
import sys

phase = 0
columns_to_use = []
columns_with_desc = []
display_table = []

# Get the observation file and open via TaQL
obstable = tables.table(sys.argv[1])
# If columns not specified in cmd, list cols in main table and get user input
if len(sys.argv) < 3:
    print("Possible columns to use")
    cols = obstable.colnames()
    print(cols)
    user_data = input("Enter comma separated list of columns to use (a, b, c, ...):")
    columns_to_use = user_data.split(", ")
# Otherwise use args from command line
else:
    columns_to_use = sys.argv[2:]

if "DATA" in columns_to_use:
    phase = int(input("Enter data phase to get:"))
max_row = int(input("Enter number of rows to retrieve:"))

#For each row the user requests get the relevant data
for i in range(0,max_row):
    row = []
    for column in columns_to_use:
        # Special case for time as unix, trim to last few numbers as we we will only see change here
        if column == 'TIME' or column == 'TIME_CENTROID':
            clean_time = "..."
            clean_time += str(obstable.getcol(column,i,i+1)[0])[-20:]
            row.append(clean_time)
        # If data, handle the complex number and phase filtering
        elif column == 'DATA':
            full_number = ((obstable.getcol(column,i,i+1)[0]))[phase][phase]
            row.append(str(full_number))
        else:
            row.append(obstable.getcol(column,i,i+1)[0])
    display_table.append(row)

# Print the description of each column for reference 
print("--------------------------------")
for column in columns_to_use:
    desc = column + ": " + obstable.getcoldesc(column)['comment']
    print(desc)
print("--------------------------------\n")
# Use tabulate to print the data cleanly
print(tabulate.tabulate(display_table,headers=columns_to_use, tablefmt="outline"))
