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
# person_in_charge: mathieu.courtois at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


TEST_TABLE=PROC(nom="TEST_TABLE",op= 177,
                fr=tr("Tester une cellule ou une colonne d'une table"),
#  concept table_sdaster à tester
         TABLE           =SIMP(statut='o',typ=table_sdaster),
         FILTRE          =FACT(statut='f',max='**',
           NOM_PARA        =SIMP(statut='o',typ='TXM' ),
           CRIT_COMP       =SIMP(statut='f',typ='TXM',defaut="EQ",
                                 into=("EQ","LT","GT","NE","LE","GE","VIDE",
                                       "NON_VIDE","MAXI","MAXI_ABS","MINI","MINI_ABS") ),
           b_vale          =BLOC(condition = """(is_in("CRIT_COMP", ('EQ','NE','GT','LT','GE','LE')))""",
              regles=(UN_PARMI('VALE','VALE_I','VALE_K','VALE_C',),),
              VALE            =SIMP(statut='f',typ='R',),
              VALE_I          =SIMP(statut='f',typ='I',),
              VALE_C          =SIMP(statut='f',typ='C',),
              VALE_K          =SIMP(statut='f',typ='TXM' ),),

           CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU") ),
           PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-3 ),
         ),
         NOM_PARA        =SIMP(statut='o',typ='TXM' ),
         INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2) ),
         **C_TEST_REFERENCE('TABLE', max='**')
)  ;
