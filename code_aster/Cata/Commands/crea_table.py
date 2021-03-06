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


def crea_table_prod(TYPE_TABLE, **args):
   """Typage du concept résultat
   """
   if TYPE_TABLE == 'TABLE_FONCTION':
      return table_fonction
   elif TYPE_TABLE == 'TABLE_CONTENEUR':
      return table_container
   else:
      return table_sdaster

CREA_TABLE=OPER(nom="CREA_TABLE",op=36,sd_prod=crea_table_prod,
                fr=tr("Création d'une table à partir d'une fonction ou de deux listes"),
                reentrant='f',

           regles=(EXCLUS('FONCTION','LISTE','RESU'),),

           reuse=SIMP(statut='c', typ=CO),
           LISTE=FACT(statut='f',max='**',
                 fr=tr("Creation d'une table a partir de listes"),
                 regles=(UN_PARMI('LISTE_I','LISTE_R','LISTE_K')),
                        PARA     =SIMP(statut='o',typ='TXM'),
                        TYPE_K   =SIMP(statut='f',typ='TXM',defaut='K8',
                                    into=('K8','K16','K24')),
                        NUME_LIGN=SIMP(statut='f',typ='I',max='**'),
                        LISTE_I  =SIMP(statut='f',typ='I',max='**'),
                        LISTE_R  =SIMP(statut='f',typ='R',max='**'),
                        LISTE_K  =SIMP(statut='f',typ='TXM', max='**'),
           ),
           FONCTION=FACT(statut='f',
                    fr=tr("Creation d'une table a partir d'une fonction"),
                        FONCTION=SIMP(statut='o',typ=(fonction_c,fonction_sdaster)),
                        PARA=SIMP(statut='f',typ='TXM',min=2,max=2),
           ),
           RESU=FACT(statut='f',max=1,
                fr=tr("Creation d'une table a partir d'un resultat ou d'un champ"),
                regles=(UN_PARMI('CHAM_GD','RESULTAT'),
                        UN_PARMI('TOUT_CMP','NOM_CMP','NOM_VARI'),
                        PRESENT_ABSENT('TOUT','GROUP_MA','GROUP_NO','MAILLE','NOEUD',),
                        AU_MOINS_UN('TOUT','GROUP_MA','GROUP_NO','MAILLE','NOEUD',),
                        ),
                        CHAM_GD  =SIMP(statut='f',typ=cham_gd_sdaster),
                        RESULTAT =SIMP(statut='f',typ=(resultat_sdaster) ),
                        b_resultat   =BLOC(condition = """exists('RESULTAT')""",
                               regles=(EXCLUS('TOUT_ORDRE','NUME_ORDRE','LIST_ORDRE','INST','LIST_INST',
                                              'MODE','LIST_MODE','FREQ','LIST_FREQ'),),
                               NOM_CHAM        =SIMP(statut='o',typ='TXM',validators=NoRepeat(),into=C_NOM_CHAM_INTO()),
                               TOUT_ORDRE      =SIMP(statut='f',typ='TXM',into=("OUI",) ),
                               NUME_ORDRE      =SIMP(statut='f',typ='I',max='**'),
                               LIST_ORDRE      =SIMP(statut='f',typ=(listis_sdaster) ),
                               INST            =SIMP(statut='f',typ='R',max='**'),
                               LIST_INST       =SIMP(statut='f',typ=(listr8_sdaster) ),
                               MODE            =SIMP(statut='f',typ='I',max='**'),
                               LIST_MODE       =SIMP(statut='f',typ=(listis_sdaster) ),
                               FREQ            =SIMP(statut='f',typ='R',max='**'),
                               LIST_FREQ       =SIMP(statut='f',typ=(listr8_sdaster) ),
                               CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU",) ),
                               b_prec_rela=BLOC(condition="""equal_to('CRITERE', 'RELATIF')""",
                                       PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
                               b_prec_abso=BLOC(condition="""equal_to('CRITERE', 'ABSOLU')""",
                                       PRECISION       =SIMP(statut='o',typ='R',),),
                            ),
                        b_cham_gd   =BLOC(condition = """exists('CHAM_GD')""",
                               CARA_ELEM       =SIMP(statut='f',typ=cara_elem),),
                      TOUT_CMP        =SIMP(statut='f',typ='TXM',into=("OUI",) ),
                      NOM_CMP         =SIMP(statut='f',typ='TXM',max='**'),
                      NOM_VARI        =SIMP(statut='f',typ='TXM',max='**'),
                      TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
                      GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                      GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                      MAILLE          =SIMP(statut='c',typ=ma  ,validators=NoRepeat(),max='**'),
                      NOEUD           =SIMP(statut='c',typ=no  ,validators=NoRepeat(),max='**'),
                      ),

           TYPE_TABLE = SIMP(statut='f', typ='TXM', defaut="TABLE",
                             into=('TABLE', 'TABLE_FONCTION', 'TABLE_CONTENEUR'),),

           TITRE=SIMP(statut='f',typ='TXM'),
)  ;
