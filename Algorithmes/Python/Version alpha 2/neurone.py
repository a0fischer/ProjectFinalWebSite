import time as t
import random as r
import proteine as p
import cerveau as c

class Neuron():
	def __init__(self, r, x, y):
		self.r=r #r est le rayon du neurone
		self.state=0   #l'etat du neurone qui varie de 0 a... 10 ? 10 est le plus grave
                #coordonnees du neurone :
		self.x=x
		self.y=y
		self.proteins=[] #tableau de proteines
		self.color="black"
	def apparition_protein(self, Tprotein): #fait apparaitre une proteine selon une certaine probabilite
                if r.random() < 0.1:
                        #ajout d'une proteine de rayon 5 et des memes coordonnes que le neurone, se deplacant dans une direction aleatoire
                        Tprotein.append(p.Protein(Tprotein[0].r, self.x, self.y, r.randint(0,360)))
                                           

if __name__=='__main__' :
        neuron=Neuron(20,5,60)
        brain=c.BrainView(400,400)
        neuron.apparition_proteine(brain)
