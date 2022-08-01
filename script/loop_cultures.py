# -*- coding: utf-8 -*-
"""
Created on Fri Jul 29 17:01:31 2022

@author: Christian Sommer
"""
import pandas as pd

clist = pd.read_excel (r'D:\SOMMER\git\roceeh2wiki\data\wiki_cultures.xlsx')
clist = clist.query('use=="T"') # Exlude unused rows


for i,j in clist.iterrows():
    print(i, j.enwiki_title)
