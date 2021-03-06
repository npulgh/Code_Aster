# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
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
# person_in_charge: irmela.zentner at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


GENE_FONC_ALEA=OPER(nom="GENE_FONC_ALEA",op= 118,sd_prod=interspectre,
                    fr=tr("Génération de la fonction temporelle à partir d une matrice interspectrale"),
                    reentrant='n',
         INTE_SPEC       =SIMP(statut='o',typ=interspectre),
         NUME_VITE_FLUI  =SIMP(statut='f',typ='I' ),
         INTERPOL        =SIMP(statut='f',typ='TXM',defaut="OUI",into=("NON","OUI") ),
         b_interpol_oui    =BLOC(condition = """equal_to("INTERPOL", 'OUI') """,fr=tr("Parametres cas interpolation autorisee"),
           DUREE_TIRAGE    =SIMP(statut='f',typ='R' ),
           FREQ_INIT       =SIMP(statut='f',typ='R' ),
           FREQ_FIN        =SIMP(statut='f',typ='R' ),
             ),
         NB_POIN         =SIMP(statut='f',typ='I'),
         NB_TIRAGE       =SIMP(statut='f',typ='I',defaut= 1 ),
         INIT_ALEA       =SIMP(statut='f',typ='I'),
         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=( 1 , 2) ),
         TITRE           =SIMP(statut='f',typ='TXM'),
)  ;
