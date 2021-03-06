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
# person_in_charge: samuel.geniaut at edf.fr

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


POST_K1_K2_K3=MACRO(nom="POST_K1_K2_K3",
                    op=OPS('Macro.post_k1_k2_k3_ops.post_k1_k2_k3_ops'),
                    sd_prod=table_sdaster,
                    fr=tr("Calcul des facteurs d'intensité de contraintes en 2D et en 3D par "
                         "extrapolation des sauts de déplacements sur les lèvres de la fissure"),
                    reentrant='n',

           regles=(UN_PARMI('FISSURE','FOND_FISS'),),

         FOND_FISS     =SIMP(statut='f',typ=fond_fiss),
         FISSURE       =SIMP(statut='f',typ=fiss_xfem),
         RESULTAT      =SIMP(statut='o',typ=(evol_elas,evol_noli,mode_meca),
                             fr=tr("Déplacement des noeuds de la lèvre supérieure et inférieure")),
         MATER         =SIMP(statut='f',typ=mater_sdaster,
                             fr=tr("Matériau homogène et isotrope")),
         NB_NOEUD_COUPE=SIMP(statut='f',typ='I',defaut=5,val_min = 3),

#        bloc correspondant a la donnee du fond de fissure pour les fissures maillees
         b_fond_fiss   =BLOC (condition="""exists("FOND_FISS")""",

              b_no_mod =BLOC (condition="""is_type("RESULTAT")!= mode_meca""",
                        TYPE_MAILLAGE = SIMP(statut='f',typ='TXM',into=("LIBRE","REGLE"),defaut="REGLE"),
                             ),
              b_mod    =BLOC (condition="""is_type("RESULTAT")== mode_meca""",
                                  TYPE_MAILLAGE = SIMP(statut='f',typ='TXM',into=("REGLE",),defaut="REGLE"),
                             ),

                         NOEUD         = SIMP(statut='c',typ=no  ,validators=NoRepeat(),max='**'),
                         GROUP_NO      = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                         SANS_NOEUD    = SIMP(statut='c',typ=no  ,validators=NoRepeat(),max='**'),
                         SANS_GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                         TOUT          = SIMP(statut='f',typ='TXM',into=("OUI",) ),
                         ABSC_CURV_MAXI=SIMP(statut='f',typ='R',
                             fr=tr("Distance maximum à partir du fond de fissure à utiliser pour le calcul")),
                         ),

#        bloc correspondant a la donnee de la fissure pour les fissures X-FEM
         b_fissure     =BLOC (condition="""exists("FISSURE")""",
                         NB_POINT_FOND = SIMP(statut='f',typ='I' ,),
                         NUME_FOND     = SIMP(statut='f',typ='I',defaut=1),
                         ABSC_CURV_MAXI=SIMP(statut='f',typ='R',
                             fr=tr("Distance maximum à partir du fond de fissure à utiliser pour le calcul")),
                         ),


         
         PREC_VIS_A_VIS=SIMP(statut='f',typ='R',defaut=0.1),

         b_mod_meca  =BLOC (condition="""is_type("RESULTAT")== mode_meca """,      
         TOUT_ORDRE    =SIMP(statut='f',typ='TXM',into=("OUI",) ),
         NUME_ORDRE    =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
         LIST_ORDRE    =SIMP(statut='f',typ=listis_sdaster),
         TOUT_MODE       =SIMP(statut='f',typ='TXM',into=("OUI",) ),
         NUME_MODE       =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
         LIST_MODE       =SIMP(statut='f',typ=listis_sdaster),
         FREQ          =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
         LIST_FREQ     =SIMP(statut='f',typ=listr8_sdaster),
             b_acce_reel     =BLOC(condition="""(exists("FREQ")) or (exists("LIST_FREQ"))""",
               CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU") ),
               b_prec_rela=BLOC(condition="""(equal_to("CRITERE", 'RELATIF'))""",
                   PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
               b_prec_abso=BLOC(condition="""(equal_to("CRITERE", 'ABSOLU'))""",
                   PRECISION       =SIMP(statut='o',typ='R',),),
             ),
             ),
         b_no_mod_meca  =BLOC (condition="""is_type("RESULTAT")!= mode_meca """,
         TOUT_ORDRE    =SIMP(statut='f',typ='TXM',into=("OUI",) ),
         NUME_ORDRE    =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
         LIST_ORDRE    =SIMP(statut='f',typ=listis_sdaster),   
         INST          =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
         LIST_INST     =SIMP(statut='f',typ=listr8_sdaster),
             b_acce_reel     =BLOC(condition="""(exists("INST"))or(exists("LIST_INST"))""",
               CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU") ),
               b_prec_rela=BLOC(condition="""(equal_to("CRITERE", 'RELATIF'))""",
                   PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
               b_prec_abso=BLOC(condition="""(equal_to("CRITERE", 'ABSOLU'))""",
                   PRECISION       =SIMP(statut='o',typ='R',),),
             ),
             ),
         INFO          =SIMP(statut='f',typ='I',defaut=1,into=(1,2)),
         TITRE         =SIMP(statut='f',typ='TXM'),
)  ;
