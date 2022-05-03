# import required module
import os
# assign directory
directory = '.'
 

def wstaw(file):
    fwoe = file.replace("./", "")
    fwoe = fwoe.replace(".png", "")
    cap = fwoe.replace('_', " ")
    print("% ", cap)
    print("\\begin{figure}")
    ig = "    \\includegraphics[width=9cm]{wyniki/" + fwoe + "}"
    print(ig)
    print("    \\caption{",cap,"}")
    print("\\end{figure}")
    print("")



# iterate over files in
# that directory
file_list = os.listdir(directory)
sorted_list = sorted(file_list, key=str.swapcase)
for filename in sorted_list:
    f = os.path.join(directory, filename)
    # checking if it is a file
    if os.path.isfile(f):
        wstaw(f)
