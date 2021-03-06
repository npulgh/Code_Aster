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


POST_DYNA_ALEA=MACRO(nom="POST_DYNA_ALEA",
                     op=OPS('Macro.post_dyna_alea_ops.post_dyna_alea_ops'),
                     sd_prod=table_sdaster,
                     fr=tr("Traitements statistiques de résultats de type interspectre "
                          "et impression sur fichiers"),
                     reentrant='n',
         regles=(UN_PARMI('FRAGILITE','INTERSPECTRE'),),
         FRAGILITE=FACT(statut='f',
                        fr=tr("donnees pour courbe de fragilite"),
                        max=1,
                        regles=(UN_PARMI('VALE','LIST_PARA'),),
                        TABL_RESU  =SIMP(statut='o',typ=table_sdaster),
                        VALE       = SIMP(statut='f',typ='R', min=1,validators=NoRepeat(),max='**' ),
                        LIST_PARA  = SIMP(statut='f',typ=listr8_sdaster),
                        METHODE    = SIMP(statut='o',typ='TXM',into=("EMV","REGRESSION") ),
                        a_methode =BLOC(condition = """equal_to("METHODE", 'REGRESSION')""", 
                            SEUIL     = SIMP(statut='o',typ='R' ),  ), 
                        b_methode =BLOC(condition = """equal_to("METHODE", 'EMV')""",
                           SEUIL     = SIMP(statut='f',typ='R' ),   
                           AM_INI     = SIMP(statut='o',typ='R' ),
                           BETA_INI   = SIMP(statut='f',typ='R',defaut= 0.3 ),
                           FRACTILE   = SIMP(statut='f',typ='R', min=1,validators=NoRepeat(),max='**'),
                           b_inte_spec_f  = BLOC(condition="""exists("FRACTILE")""",
                               NB_TIRAGE =SIMP(statut='f',typ='I' ),),),),

         INTERSPECTRE=FACT(statut='f',
                           max=1,
                           fr=tr("donnees pour interspectre"),
                           regles=(UN_PARMI('NOEUD_I','NUME_ORDRE_I','OPTION'),),
                           INTE_SPEC       =SIMP(statut='o',typ=interspectre),
                           NUME_ORDRE_I    =SIMP(statut='f',typ='I',max='**' ),
                           NOEUD_I         =SIMP(statut='f',typ=no,max='**'),
                           OPTION          =SIMP(statut='f',typ='TXM',into=("DIAG","TOUT",) ),
                           b_nume_ordre_i =BLOC(condition = """exists("NUME_ORDRE_I")""",
                               NUME_ORDRE_J    =SIMP(statut='o',typ='I',max='**' ),
                                        ),
                           b_noeud_i      =BLOC(condition = """exists("NOEUD_I")""",
                               NOEUD_J         =SIMP(statut='o',typ=no,max='**'),
                               NOM_CMP_I       =SIMP(statut='o',typ='TXM',max='**' ),
                               NOM_CMP_J       =SIMP(statut='o',typ='TXM',max='**' ),
                                        ),
                           MOMENT          =SIMP(statut='f',typ='I',max='**',
                                                 fr=tr("Moments spectraux en complément des cinq premiers")),
                           DUREE           =SIMP(statut='f',typ='R',
                                                 fr=tr("durée de la phase forte pour facteur de peak"))),
         TITRE           =SIMP(statut='f',typ='TXM' ),
         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=(1,2) ),
)
