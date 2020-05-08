import math as m
import cerveau as c
import neurone as n
import random as r


class Protein():
	def __init__(self, r, x, y, angle):
		self.r=r #r est le rayon de la proteine
		self.color="yellow"  #deux couleurs possibles : yellow = etat normal,  red = etat infectieux de la proteine
		#coordonnees de la proteine :
		self.x=x
		self.y=y
		self.leader=self #definie le leader (la proteine suivi) comme elle meme
		self.led=self #la protein qui la suit est elle meme
		self.direction=angle #la proteine se deplace selon un angle en degres

	def change_state(self, protein):
                #la proteine a une chance de changer d'etat toute seule et accrue si elle touche une proteine
		if r.random()<0.0001:
			self.color="red"
		if self.distance(protein)<=self.r+protein.r and protein.color=="red":
                        #si une proteine en touche une autre qui est rouge, elle devient rouge
                        self.color="red"
        
	def move(self, c):
                if r.random()<0.000001:
                        self.leader.leader.direction+=r.randint(1,5)
                        self.direction=self.leader.leader.direction
                #la proteine se deplace selon un angle (entier), elle doit suivre le leader
                self.x=self.x+int(10*m.cos(m.degrees(self.leader.leader.direction)))
                self.y=self.y+int(10*m.sin(m.degrees(self.leader.leader.direction)))
                
                if (self.x < 0) : 
                    self.x = c.width
                elif (self.x > c.width) :
                    self.x = 0
                
                if (self.y < 0) :
                    self.y = c.height
                elif (self.y > c.height) : 
                    self.y = 0                    
                     
        
	def hook(self, protein):
                #deux proteines (d'etat evil seulement je crois) peuvent s'accrocher
                if self.distance(protein)<=protein.r+self.r :
                        
                        self.leader.leader=protein.leader
                        self.leader=protein.leader
                        self.direction=protein.leader.direction
                        #t'inquietes ca marche
                        #si si je t'assure
                        #aiiiie cooonfiansssssse
                        #En vrai ca marche pas parfaitement bien

       
	def detach(self):
                #une proteine accrochee ont une probabilite de se decrocher
                #ce qui revient a tranformer le leader en elle meme 
                if r.random()<0.0000000000001:
                        self.leader=self

	def distance(self, cercle): #mesure la distance entre la proteine
                #et une autre proteine ou le neurone
                return m.sqrt((self.x-cercle.x)*(self.x-cercle.x)+(self.y-cercle.y)*(self.y-cercle.y))
                
	def degrade(self, neuron): #neuron est le tableau de neurones de brain
                #on test si la proteine est assez proche d'un neurone
                for n in neuron:
                        if self.distance(n)<=self.r+n.r and n.state<10: #je fixe le maximum de degradation a 10 mais on peut changer
                                n.state+=1
                #mais si une proteine passe sur le neurone, il faut prevoir qu'elle ne se deplacera pas pareil

                

if __name__=='__main__' :
        p=Protein(5,0,0,60)
        neuron=[n.Neuron(10,20,1)]
        p.degrade(neuron)
        Tprot=[]
        for i in range(10):
                #juste pour tester si les proteines s'accrochent comme il faut
                Tprot.append(Protein(20,i,i,r.randint(0,360)))
        p.run_prot(Tprot)



        
