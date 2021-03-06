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
# person_in_charge: mathieu.corus at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


NUME_DDL_GENE=OPER(nom="NUME_DDL_GENE",op= 127,sd_prod=nume_ddl_gene,
                   fr=tr("Etablissement de la numérotation des ddl d'un modèle etabli en coordonnées généralisees"),
                    reentrant='n',
         regles=UN_PARMI('MODELE_GENE','BASE'),
         MODELE_GENE     =SIMP(statut='f',typ=modele_gene ),
             b_modele_gene     =BLOC(condition = """exists("MODELE_GENE")""",
               STOCKAGE     =SIMP(statut='f',typ='TXM',defaut="LIGN_CIEL",into=("LIGN_CIEL","PLEIN") ),
               METHODE            =SIMP(statut='f',typ='TXM',defaut="CLASSIQUE",into=("INITIAL","CLASSIQUE","ELIMINE") ),
                                    ),
         BASE     =SIMP(statut='f',typ=(mode_meca,mode_gene ) ),
             b_base     =BLOC(condition = """exists("BASE")""",
               STOCKAGE     =SIMP(statut='f',typ='TXM',defaut="PLEIN",into=("DIAG","PLEIN") ),
               NB_VECT     =SIMP(statut='f',typ='I'),
                             ),
)  ;
