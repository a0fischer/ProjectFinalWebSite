import tkinter as tk
import time as t
import neurone as n
import proteine as p
import random as r

class BrainView(tk.Canvas):
	def __init__(self,wi, he):
		self.fenetre=tk.Tk()
		tk.Canvas.__init__(self,self.fenetre,width=wi+50, height=he+50)
		self.pack()
		self.create_rectangle(0,0,wi,he,fill='white')
		self.width=wi
		self.height=he
		self.neuron=[] #definition d'un tableau de neurones
		self.TabProtein=[]#definition d'un tableau de proteines
		self.time=t.time()
	def draw_neurone(self, n):
                self.create_oval(n.x,n.y,n.x+2*n.r,n.y+2*n.r,fill=n.color)

	def draw_proteins(self, p):
                self.create_oval(p.x,p.y,p.x+p.r*2,p.y+p.r*2,fill=p.color)

	def run_protein_and_neuron(self): #on fait toutes les actions sur les neurones et proteines
                for n in self.neuron:
                        n.apparition_protein(self.TabProtein)
                        self.draw_neurone(n)
                for i in range(len(self.TabProtein)): 
                        self.TabProtein[i].detach()
                        for j in range(i+1,len(self.TabProtein)):
                                self.TabProtein[i].hook(self.TabProtein[j])
                                self.TabProtein[j].hook(self.TabProtein[i])
                                self.TabProtein[i].change_state(self.TabProtein[j])
                                self.TabProtein[j].change_state(self.TabProtein[i])
                        self.TabProtein[i].move(self)
                        self.draw_proteins(self.TabProtein[i])

def myfunction():
	brain.delete('all') #truc qui efface les objets enregistres par tkinter, ca evite les ralentissements
	brain.create_rectangle(0,0,brain.width, brain.height, fill='white')
	brain.run_protein_and_neuron()
	brain.fenetre.after(1, myfunction) #myfuncton est rappelee toutes les 10 ms


if __name__=='__main__':
        w=800
        h=800
        brain=BrainView(w,h)
        for _ in range(100):
                #juste pour tester si les proteines s'accrochent comme il faut
                brain.TabProtein.append(p.Protein(10,r.randint(300,500),r.randint(300, 500),r.randint(0,360)))
        brain.neuron.append(n.Neuron(50,100,200))
        myfunction()
        brain.fenetre.mainloop()

