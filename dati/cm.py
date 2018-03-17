import seaborn as sn
import pandas as pd
import matplotlib.pyplot as plt
#plt.use('Agg')  

array = [[93.74,6.26], [9.14,90.86]]


df_cm = pd.DataFrame(array, index = ["Predicted  false", "Predicted true"],# [i for i in "AB"],
                  columns = ["Real false","Real True"])#[i for i in "AB"])
plt.figure(figsize = (10,7))
pal =  sn.light_palette((210, 90, 60), input="husl", as_cmap=True, n_colors=120)#diverging_palette(240, 10, n=9)#sn.palplot(sn.light_palette("green"))
#pal = sn.palplot(sn.diverging_palette(10, 220, sep=80, n=7))s=85, l=25, 

sns_plot = sn.heatmap(df_cm, annot=True,cmap=pal,annot_kws={"size": 16}, fmt='.1f',linewidth=1.)#sn.heatmap(df_cm, annot=True)# font size
for t in sns_plot.texts: t.set_text(t.get_text() + " %")
fig = sns_plot.get_figure()
fig.savefig("output.png")

