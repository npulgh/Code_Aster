#@ MODIF co_fonction SD  DATE 19/06/2007   AUTEUR PELLET J.PELLET 
# -*- coding: iso-8859-1 -*-
#            CONFIGURATION MANAGEMENT OF EDF VERSION
# ======================================================================
# COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
# ======================================================================

import Accas
from SD import *
from sd_fonction import sd_fonction_aster

import Numeric
from math import pi

# -----------------------------------------------------------------------------
# types 'fonction' :
class fonction_class(ASSD):
   def Valeurs(self):
      pass
   def Parametres(self):
      """
      Retourne un dictionnaire contenant les parametres de la fonction ;
      le type jeveux (FONCTION, FONCT_C, NAPPE) n'est pas retourne,
      le dictionnaire peut ainsi etre fourni a CALC_FONC_INTERP tel quel.
      """
      from Utilitai.Utmess import UTMESS
      if not self.par_lot():
        TypeProl={'E':'EXCLU', 'L':'LINEAIRE', 'C':'CONSTANT' }
        objev = '%-19s.PROL' % self.get_name()
        prol = aster.getvectjev(objev)
        if prol == None:
           UTMESS('F', 'fonction.Parametres', "Objet '%s' inexistant" % objev)
        dico={
         'INTERPOL'    : [prol[1][0:3],prol[1][4:7]],
         'NOM_PARA'    : prol[2][0:16].strip(),
         'NOM_RESU'    : prol[3][0:16].strip(),
         'PROL_DROITE' : TypeProl[prol[4][1]],
         'PROL_GAUCHE' : TypeProl[prol[4][0]],
        }
      elif hasattr(self,'etape') and self.etape.nom=='DEFI_FONCTION' :
        dico={
         'INTERPOL'    : self.etape['INTERPOL'],
         'NOM_PARA'    : self.etape['NOM_PARA'],
         'NOM_RESU'    : self.etape['NOM_RESU'],
         'PROL_DROITE' : self.etape['PROL_DROITE'],
         'PROL_GAUCHE' : self.etape['PROL_GAUCHE'],
        }
        if   type(dico['INTERPOL']) == tuple:
                  dico['INTERPOL']=list(dico['INTERPOL'])
        elif type(dico['INTERPOL']) == str:
                  dico['INTERPOL']=[dico['INTERPOL'],]
        if len(dico['INTERPOL'])==1 :
           dico['INTERPOL']=dico['INTERPOL']*2
      else:
         raise Accas.AsException("Erreur dans fonction.Parametres en PAR_LOT='OUI'")
      return dico
   def Trace(self,FORMAT='TABLEAU',**kargs):
      """Trac� d'une fonction"""
      if self.par_lot() :
         raise Accas.AsException("Erreur dans fonction.Trace en PAR_LOT='OUI'")
      from Utilitai.Graph import Graph
      gr=Graph()
      gr.AjoutCourbe(Val=self.Valeurs(),
            Lab=[self.Parametres()['NOM_PARA'],self.Parametres()['NOM_RESU']])
      gr.Trace(FORMAT=FORMAT,**kargs)

# -----------------------------------------------------------------------------
class fonction_sdaster(fonction_class, sd_fonction_aster):
   def convert(self,arg='real'):
      """
      Retourne un objet de la classe t_fonction
      repr�sentation python de la fonction
      """
      from Utilitai.t_fonction import t_fonction,t_fonction_c
      if arg=='real' :
        return t_fonction(self.Absc(),
                          self.Ordo(),
                          self.Parametres(),
                          nom=self.nom)
      elif arg=='complex' :
        return t_fonction_c(self.Absc(),
                            self.Ordo(),
                            self.Parametres(),
                            nom=self.nom)
   def Valeurs(self) :
      """
      Retourne deux listes de valeurs : abscisses et ordonnees
      """
      from Utilitai.Utmess import UTMESS
      if not self.par_lot():
        vale = '%-19s.VALE' % self.get_name()
        lbl = aster.getvectjev(vale)
        if lbl == None:
           UTMESS('F', 'fonction.Valeurs', "Objet '%s' inexistant" % vale)
        lbl = list(lbl)
        dim = len(lbl)/2
        lx = lbl[0:dim]
        ly = lbl[dim:2*dim]
      elif hasattr(self, 'etape') and self.etape.nom == 'DEFI_FONCTION' :
         if self.etape['VALE'] != None:
            lbl = list(self.etape['VALE'])
            dim = len(lbl)
            lx = [lbl[i] for i in range(0,dim,2)]
            ly = [lbl[i] for i in range(1,dim,2)]
         elif self.etape['VALE_PARA']!=None:
            lx = self.etape['VALE_PARA'].Valeurs()
            ly = self.etape['VALE_FONC'].Valeurs()
      else:
         raise Accas.AsException("Erreur (fonction.Valeurs) : ne fonctionne en " \
               "PAR_LOT='OUI' que sur des fonctions produites par DEFI_FONCTION " \
               "dans le jdc courant.")
      return [lx, ly]
   def Absc(self):
      """Retourne la liste des abscisses"""
      return self.Valeurs()[0]
   def Ordo(self):
      """Retourne la liste des ordonn�es"""
      return self.Valeurs()[1]
   def __call__(self,val):
      ### Pour EFICAS : substitution de l'instance de classe
      ### parametre par sa valeur
      if isinstance(val, ASSD):
         val=val.valeur
      ###
      __ff=self.convert()
      return __ff(val)

# -----------------------------------------------------------------------------
class para_sensi(fonction_sdaster):
   pass

# -----------------------------------------------------------------------------
class fonction_c(fonction_class, sd_fonction_aster):
   def convert(self,arg='real'):
      """
      Retourne un objet de la classe t_fonction ou t_fonction_c,
      repr�sentation python de la fonction complexe
      """
      from Utilitai.t_fonction import t_fonction,t_fonction_c
      if arg=='real' :
        return t_fonction(self.Absc(),
                          self.Ordo(),
                          self.Parametres(),
                          nom=self.nom)
      elif arg=='imag' :
        return t_fonction(self.Absc(),
                          self.OrdoImg(),
                          self.Parametres(),
                          nom=self.nom)
      elif arg=='modul' :
        modul=Numeric.sqrt(Numeric.array(self.Ordo())**2+Numeric.array(self.OrdoImg())**2)
        return t_fonction(self.Absc(),
                          modul,
                          self.Parametres(),
                          nom=self.nom)
      elif arg=='phase' :
        phase=Numeric.arctan2(Numeric.array(self.OrdoImg()),Numeric.array(self.Ordo()))
        phase=phase*180./pi
        return t_fonction(self.Absc(),
                          phase,
                          self.Parametres(),
                          nom=self.nom)
      elif arg=='complex' :
        return t_fonction_c(self.Absc(),
                            map(complex,self.Ordo(),self.OrdoImg()),
                            self.Parametres(),
                          nom=self.nom)
   def Valeurs(self) :
      """
      Retourne trois listes de valeurs : abscisses, parties reelles et imaginaires.
      """
      from Utilitai.Utmess import UTMESS
      if not self.par_lot():
         vale = '%-19s.VALE' % self.get_name()
         lbl = aster.getvectjev(vale)
         if lbl == None:
            UTMESS('F', 'fonction.Valeurs', "Objet '%s' inexistant" % vale)
         lbl = list(lbl)
         dim=len(lbl)/3
         lx=lbl[0:dim]
         lr=[]
         li=[]
         for i in range(dim):
            lr.append(lbl[dim+2*i])
            li.append(lbl[dim+2*i+1])
      elif hasattr(self, 'etape') and self.etape.nom == 'DEFI_FONCTION':
         lbl=list(self.etape['VALE_C'])
         dim=len(lbl)
         lx=[lbl[i] for i in range(0,dim,3)]
         lr=[lbl[i] for i in range(1,dim,3)]
         li=[lbl[i] for i in range(2,dim,3)]
      else:
         raise Accas.AsException("Erreur (fonction_c.Valeurs) : ne fonctionne en " \
               "PAR_LOT='OUI' que sur des fonctions produites par DEFI_FONCTION " \
               "dans le jdc courant.")
      return [lx, lr, li]
   def Absc(self):
      """Retourne la liste des abscisses"""
      return self.Valeurs()[0]
   def Ordo(self):
      """Retourne la liste des parties r�elles des ordonn�es"""
      return self.Valeurs()[1]
   def OrdoImg(self):
      """Retourne la liste des parties imaginaires des ordonn�es"""
      return self.Valeurs()[2]
   def Trace(self,FORMAT='TABLEAU',**kargs):
      """Trac� d'une fonction complexe"""
      if self.par_lot() :
         raise Accas.AsException("Erreur dans fonction_c.Trace en PAR_LOT='OUI'")
      from Utilitai.Graph import Graph
      gr=Graph()
      gr.AjoutCourbe(Val=self.Valeurs(),
       Lab=[self.Parametres()['NOM_PARA'],self.Parametres()['NOM_RESU'],'IMAG'])
      gr.Trace(FORMAT=FORMAT,**kargs)
   def __call__(self,val):
      ### Pour EFICAS : substitution de l'instance de classe
      ### parametre par sa valeur
      if isinstance(val, ASSD):
         val=val.valeur
      ###
      __ff=self.convert(arg='complex')
      return __ff(val)

# -----------------------------------------------------------------------------
class nappe_sdaster(fonction_class, sd_fonction_aster):
   def convert(self):
      """
      Retourne un objet de la classe t_nappe, repr�sentation python de la nappe
      """
      from Utilitai.t_fonction import t_fonction,t_nappe
      para=self.Parametres()
      vale=self.Valeurs()
      l_fonc=[]
      i=0
      for pf in para[1] :
          para_f={'INTERPOL'    : pf['INTERPOL_FONC'],
                  'PROL_DROITE' : pf['PROL_DROITE_FONC'],
                  'PROL_GAUCHE' : pf['PROL_GAUCHE_FONC'],
                  'NOM_PARA'    : para[0]['NOM_PARA_FONC'],
                  'NOM_RESU'    : para[0]['NOM_RESU'],
                 }
          l_fonc.append(t_fonction(vale[1][i][0],vale[1][i][1],para_f))
          i+=1
      return t_nappe(vale[0],
                     l_fonc,
                     para[0],
                     nom=self.nom)
   def Valeurs(self):
      """
      Retourne la liste des valeurs du parametre,
      et une liste de couples (abscisses,ordonnees) de chaque fonction.
      """
      from Utilitai.Utmess import UTMESS
      if self.par_lot():
         raise Accas.AsException("Erreur dans nappe.Valeurs en PAR_LOT='OUI'")
      nsd = '%-19s' % self.get_name()
      dicv=aster.getcolljev(nsd+'.VALE')
      # les cles de dicv sont 1,...,N (indice du parametre)
      lpar=aster.getvectjev(nsd+'.PARA')
      if lpar == None:
         UTMESS('F', 'fonction.Valeurs', "Objet '%s' inexistant" % (nsd+'.PARA'))
      lval=[]
      for k in range(len(dicv)):
         lbl=dicv[k+1]
         dim=len(lbl)/2
         lval.append([lbl[0:dim],lbl[dim:2*dim]])
      return [list(lpar),lval]
   def Parametres(self):
      """
      Retourne un dictionnaire contenant les parametres de la nappe,
      le type jeveux (NAPPE) n'est pas retourne,
      le dictionnaire peut ainsi etre fourni a CALC_FONC_INTERP tel quel,
      et une liste de dictionnaire des parametres de chaque fonction.
      """
      from Utilitai.Utmess import UTMESS
      if self.par_lot():
         raise Accas.AsException("Erreur dans nappe.Parametres en PAR_LOT='OUI'")
      TypeProl={'E':'EXCLU', 'L':'LINEAIRE', 'C':'CONSTANT' }
      objev = '%-19s.PROL' % self.get_name()
      prol=aster.getvectjev(objev)
      if prol == None:
         UTMESS('F', 'fonction.Parametres', "Objet '%s' inexistant" % objev)
      dico={
         'INTERPOL'      : [prol[1][0:3],prol[1][4:7]],
         'NOM_PARA'      : prol[2][0:16].strip(),
         'NOM_RESU'      : prol[3][0:16].strip(),
         'PROL_DROITE'   : TypeProl[prol[4][1]],
         'PROL_GAUCHE'   : TypeProl[prol[4][0]],
         'NOM_PARA_FONC' : prol[5][0:4].strip(),
      }
      lparf=[]
      nbf=(len(prol)-6)/2
      for i in range(nbf):
         dicf={
            'INTERPOL_FONC'    : [prol[6+i*2][0:3],prol[6+i*2][4:7]],
            'PROL_DROITE_FONC' : TypeProl[prol[7+i*2][1]],
            'PROL_GAUCHE_FONC' : TypeProl[prol[7+i*2][0]],
         }
         lparf.append(dicf)
      return [dico,lparf]
   def Absc(self):
      """Retourne la liste des abscisses"""
      return self.Valeurs()[0]
   def Trace(self,FORMAT='TABLEAU',**kargs):
      """Trac� d'une nappe"""
      if self.par_lot():
         raise Accas.AsException("Erreur dans nappe.Trace en PAR_LOT='OUI'")
      from Utilitai.Graph import Graph
      gr=Graph()
      lv=self.Valeurs()[1]
      dp=self.Parametres()[0]
      for lx,ly in lv:
         gr.AjoutCourbe(Val=[lx,ly], Lab=[dp['NOM_PARA_FONC'],dp['NOM_RESU']])
      gr.Trace(FORMAT=FORMAT,**kargs)
