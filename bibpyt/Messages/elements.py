#@ MODIF elements Messages  DATE 21/06/2011   AUTEUR MACOCCO K.MACOCCO 
# -*- coding: iso-8859-1 -*-
#            CONFIGURATION MANAGEMENT OF EDF VERSION
# ======================================================================
# COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
# RESPONSABLE DELMAS J.DELMAS

def _(x) : return x

cata_msg = {

1 : _("""
 AFFE_CARA_ELEM : mot cl� GENE_TUYAU
 probl�me : OMEGA est diff�rent de OMEGA2
 omega  = %(r1)f
 omega2 = %(r2)f
"""),

2 : _("""
Erreur :
   Le calcul du chargement du au s�chage n'est pas programm� par le type d'�l�ment : %(k1)s

Conseil :
  Emettre une demande d'�volution.
"""),

3 : _("""
Vous utilisez des �l�ments de type GRILLE_MEMBRANE. Le mot clef ANGL_REP de la commande AFFE_CARA_ELEM
permet d'indiquer la direction des armatures.
La projection de ce vecteur directeur dans le plan de certains des �l�ments de GRILLE_MEMBRANE est nulle.

Conseil :
  V�rifiez les donn�es sous le mot clef ANGL_REP de la commande AFFE_CARA_ELEM.
"""),


5 : _("""
 probl�me de maillage TUYAU :
 pour une maille d�finie par les noeuds N1 N2 N3,
 le noeud N3 doit etre le noeud milieu
"""),

6 : _("""
  GENE_TUYAU
  il faut donner un vecteur non colin�aire au tuyau
"""),

7 : _("""
  -> L'angle du coude est trop grand
     ANGLE     = %(r1)f
     ANGLE MAX = %(r2)f
  -> Risque & Conseil : mailler plus fin
"""),

8 : _("""
La raideur tangente de la section est nulle.
V�rifier votre mat�riau, vous avez peut �tre d�fini un mat�riau �lasto-plastique parfait.

Risque & Conseil : mettre un l�ger �crouissage peut permettre de passer cette difficult�.
"""),


9 : _("""
 il faut renseigner le coefficient E_N  dans les cas des d�formations planes et de l'axisym�trie
 on ne regarde donc que le cas des contraintes planes.
"""),

10 : _("""
 Subroutine CHPVER :
 le champ  %(k1)s n'a pas le bon type :
   type autoris�  :%(k2)s
   type du champ  :%(k3)s
"""),

11 : _("""
 La mod�lisation utilis�e n'est pas trait�e.
"""),

12 : _("""
 nombre de couches obligatoirement sup�rieur � 0
"""),

13 : _("""
 nombre de couches limit� a 10 pour les coques 3d
"""),

14 : _("""
 le type d'�l�ment :  %(k1)s n'est pas prevu.
"""),

15 : _("""
 la nature du mat�riau  %(k1)s  n'est pas trait�e
 seules sont consid�r�es les natures : ELAS, ELAS_ISTR, ELAS_ORTH .
"""),

17 : _("""
 noeuds confondus pour un �l�ment
"""),

18 : _("""
 le nombre de noeuds d'un tuyau est diff�rent de 3 ou 4
"""),

20 : _("""
 aucun type d'�l�ments ne correspond au type demand�
"""),

21 : _("""
 pr�dicteur ELAS hors champs
"""),

24 : _("""
 derivatives of "mp" not defined
"""),

25 : _("""
 on passe en m�canisme 2
"""),

26 : _("""
 chargement en m�canisme 2 trop important
 � v�rifier
"""),

27 : _("""
 on poursuit en m�canisme 2
"""),

28 : _("""
 d�charge n�gative sans passer par meca 1
 diminuer le pas de temps
"""),

29 : _("""
 on revient en m�canisme 1
"""),

30 : _("""
 pas de retour dans meca 1 trop important
 diminuer le pas de temps
"""),

31 : _("""
 type d'�l�ment  %(k1)s  incompatible avec  %(k2)s
"""),

32 : _("""
 le comportement %(k1)s est inattendu
"""),

33 : _("""
 la convergence d'un processus it�ratif local de la loi GLRC_DAMAGE
 n'a pas �t� atteinte en 1000 it�rations :
 XM1 vaut %(r1)f
 XM2 vaut %(r2)f
 YM1 vaut %(r3)f
 YM2 vaut %(r4)f
 Si cette alarme n'est pas suivie d'une erreur fatale, alors le r�sultat
 est correct.
"""),

34 : _("""
 �l�ment non trait�  %(k1)s
"""),

35 : _("""
 pas d'excentrement avec STAT_NON_LINE
 maille  : %(k1)s
"""),

36 : _("""
 nombre de couches n�gatif ou nul :  %(k1)s
"""),

37 : _("""
 Subroutine CHPVER :
 le champ  %(k1)s n'a pas la bonne grandeur :
   grandeur autoris�e  :%(k2)s
   grandeur du champ   :%(k3)s
"""),

38 : _("""
 Le ph�nom�ne sensible %(k1)s choisi ne correspond pas au ph�nom�ne %(k2)s dont il est issu
"""),

39 : _("""
 l'axe de r�f�rence est normal � un �l�ment de plaque anisotrope
"""),

40 : _("""
  -> L'axe de r�f�rence pour le calcul du rep�re local est normal � un
     au moins un �l�ment de plaque.
  -> Risque & Conseil :
     Il faut modifier l'axe de r�f�rence (axe X par d�faut) en utilisant
     ANGL_REP ou VECTEUR.

"""),

41 : _("""
 impossibilit� :
 vous avez un materiau de type "ELAS_COQUE" et vous n'avez pas d�fini la raideur de membrane,
 ni sous la forme "MEMB_L", ni sous la forme "M_LLLL".
"""),

42 : _("""
 comportement mat�riau non admis
"""),

43 : _("""
 impossibilit� :
 vous avez un materiau de type "ELAS_COQUE" et le determinant de la sous-matrice de Hooke relative au cisaillement est nul.
"""),

46 : _("""
 nombre de couches n�gatif ou nul
"""),

48 : _("""
 impossibilit�, la surface de l'�l�ment est nulle.
"""),

49 : _("""
 l'axe de r�f�rence est normal � un �l�ment de plaque
 calcul option impossible
 orienter ces mailles
"""),

50 : _("""
 comportement �lastique inexistant
"""),

51 : _("""
  -> Le type de comportement %(k1)s n'est pas pr�vu pour le calcul de
     SIGM_ELNO. Les seuls comportements autoris�s sont :
     ELAS, ELAS_COQUE, ou ELAS_ORTH
  -> Risque & Conseil :
     Pour les autres comportements, utiliser SIEF_ELNO (efforts)
     ou SICO_ELNO (contraintes en un point de l'�paisseur).
"""),

52 : _("""
  -> Le type de comportement %(k1)s n'est pas pr�vu pour le calcul de
     SIGM_ELNO avec chargement thermique. Les seuls comportements autoris�s sont :
     ELAS, ou ELAS_ORTH
"""),

53 : _("""
 probl�me :
 temp�rature sur la maille: %(k1)s : il manque la composante "TEMP"
"""),

55 : _("""
 ELREFA inconnu:  %(k1)s
"""),

58 : _("""
 la nature du mat�riau  %(k1)s  n�cessite la d�finition du coefficient  B_ENDOGE dans DEFI_MATERIAU.
"""),

62 : _("""
 GROUP_MA :  %(k1)s  inconnu dans le maillage
"""),

64 : _("""
  le LIAISON_*** de  %(k1)s  implique les noeuds physiques  %(k2)s  et  %(k3)s et traverse l'interface
"""),

65 : _("""
  le LIAISON_*** de  %(k1)s  implique le noeud physique  %(k2)s et touche l'interface
"""),

66 : _("""
 Si vous avez renseign� le mot-cl� NOEUD_ORIG, donnez un groupe de mailles sous GROUP_MA ou une liste de mailles
 sous MAILLE. On ne r�ordonne pas les groupes de noeuds et les listes de noeuds.
"""),

67 : _("""
 Le groupe de noeuds %(k1)s n'existe pas.
"""),


68 : _("""
 Le noeud origine  %(k1)s ne fait pas partie du chemin.
"""),

69 : _("""
 Le noeud origine  %(k1)s  n'est pas une extremit�.
"""),


71 : _("""
 La recherche du noeud origine �choue
"""),

72 : _("""
 GROUP_NO orient� : noeud origine =  %(k1)s
"""),

73 : _("""
 Le GROUP_MA :  %(k1)s n'existe pas.
"""),




77 : _("""
 le noeud extremit�  %(k1)s  n'est pas le dernier noeud
"""),

78 : _("""
 GROUP_NO orient� : noeud extremit� =  %(k1)s
"""),

83 : _("""
 Le type des mailles des l�vres doit �tre quadrangle ou triangle.
"""),

84 : _("""
  %(k1)s CHAM_NO inexistant
"""),

87 : _("""
 bad definition of MP1 and MP2
"""),

88 : _("""
 Option %(k1)s n'est pas disponible pour l'�l�ment %(k2)s et la loi de comportement %(k3)s
"""),

90 : _("""
Erreur de programmation :
   L'attribut NBSIGM n'est pas d�fini pour cette mod�lisation.
Solution :
   Il faut modifier la catalogue phenomene_modelisation__.cata pour ajouter NBSIGM pour cette mod�lisation.
"""),

91 : _("""
 Les plaques multi-couches ne permettent pas de tenir compte de l'excentrement dans le calcul du cisaillement transverse.
 Les composantes SIXZ et SIYZ du tenseur de contraintes ont donc �t� mises � z�ro.
"""),

}
