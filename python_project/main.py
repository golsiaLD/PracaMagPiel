
# This is a sample Python script.

# Press ⌃R to execute it or replace it with your code.
# Press Double ⇧ to search everywhere for classes, files, tool windows, actions, and settings.

import csv
# import pandas

trans1 = {'zdecydowanie nie': 1, 'raczej nie': 2, 'nie mam zdania': 3, 'raczej tak': 4, 'zdecydowanie tak': 5}
trans2 = {1: 'zdecydowanie nie', 2: 'raczej nie', 3: 'nie mam zdania', 4: 'raczej tak', 5: 'zdecydowanie tak'}

likert = ['zdecydowanie tak', 'raczej tak', 'nie mam zdania', 'raczej nie', 'zdecydowanie nie']

Q1 = 7
Q2 = 44

offset = 6
"""
q1 = Q1 + offset
q2 = Q2 + offset"""
lista = []



def build_table(nr_pytania, pytanie, podpyt):
    # table header
    print('% pytanie:', nr_pytania, '-', pytanie)
    print('\\begin{table}[h]')
    print('\caption{' + pytanie + '}')
    print('\\centering')
    print('\\begin{tabular}{ | c | c | c |}')
    print('\hline')
    print('odpowiedź & liczność & procent\\\\')

    #check keys if they are
    if likert[2] in podpyt.keys():
        klucze = likert
    else:
        klucze = podpyt.keys()

    for key in klucze:
        print('\hline')
        if key in podpyt:
            licztejodp = podpyt[key]
        else:
            licztejodp = 0
        procenty = format(licztejodp / 115.0 * 100.0, '.1f')
        print(key, ' & ', licztejodp, ' & ' + procenty + '\% \\\\')

    # table end
    print('\hline')
    print('\end{tabular}')
    print('\label{tab:Q' + str(nr_pytania) + '}')
    print('\end{table}')

    print('\n\n')


def column2dict(llista, col):
    slow = {}
    for line in llista[1:]:

        k = line[col]
        if k not in slow.keys():
            # nie ma takiego klucza
            slow.update({k: 1})
            # dodano
        else:
            # klucz juz byl
            slow[k] = slow[k] + 1
            # zwiekszono wartosc o 1


    nr_pytania = col - offset
    pytanie = lista[0][col]

    build_table(nr_pytania, pytanie, slow)



def csv2list(filename):
    # opening the CSV file
    with open(filename, mode='r') as file:
        # reading the CSV file
        csvFile = csv.reader(file)

        # row i line <- ankietowany
        # column <- pytanie


        # read the CSV file into list of lists
        for line in csvFile:
            # dodaj do listy dwie kolumny (dwa pytania)
            lista.append(line)

        rows = len(lista)
        print('lista ma:', rows, 'wierszy')
        columns = len(lista[0])
        print('lista ma:', columns, 'kolumn')


        for col in range(Q1, Q2):
            column2dict(lista, col)


def print_hi(name):
    # Use a breakpoint in the code line below to debug your script.
    print(f'Hi, {name}')  # Press ⌘F8 to toggle the breakpoint.


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    print_hi('PyCharm')
    csv2list('../ankieta01.csv')

# See PyCharm help at https://www.jetbrains.com/help/pycharm/