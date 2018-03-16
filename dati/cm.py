import seaborn as sn
import pandas as pd
import matplotlib.pyplot as plt
matplotlib.use('Agg')
array = [[98,1.9],
     [8.4,91.6]]
df_cm = pd.DataFrame(array, index = [i for i in "AB"],
                  columns = [i for i in "AB"])
plt.figure(figsize = (10,7))
pal =  sn.light_palette((210, 90, 60), input="husl", as_cmap=True, n_colors=120)#diverging_palette(240, 10, n=9)#sn.palplot(sn.light_palette("green"))
#pal = sn.palplot(sn.diverging_palette(10, 220, sep=80, n=7))s=85, l=25, 
 
sns_plot = sn.heatmap(df_cm, annot=True,cmap=pal,annot_kws={"size": 16})#sn.heatmap(df_cm, annot=True)# font size
fig = sns_plot.get_figure()
fig.savefig("output.png")
