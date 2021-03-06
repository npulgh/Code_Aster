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
# person_in_charge: isabelle.fournier at edf.fr
#
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


IMPR_OAR =MACRO(nom="IMPR_OAR",
                op=OPS('Macro.impr_oar_ops.impr_oar_ops'),
                sd_prod=None,
                fr=tr("Impression au format OAR"),
   TYPE_CALC = SIMP(statut='o', typ='TXM',into=('COMPOSANT', 'MEF', 'TUYAUTERIE')),
   b_composant =BLOC(condition = """equal_to("TYPE_CALC", 'COMPOSANT') """,
      regles = (AU_MOINS_UN('RESU_MECA','RESU_THER')),
      DIAMETRE = SIMP(statut='o', typ='R'),
      ORIGINE  = SIMP(statut='o', typ='TXM', defaut='INTERNE', into=('INTERNE', 'EXTERNE')),
      COEF_U   = SIMP(statut='f', typ='R',   defaut=1.0),
      ANGLE_C  = SIMP(statut='o', typ='R',   defaut=0.0),
      REVET    = SIMP(statut='f', typ='TXM', defaut='NON', into=('OUI', 'NON')),
      RESU_MECA = FACT(statut='f', max='**',
         NUM_CHAR  = SIMP(statut='o', typ='I'),
         TYPE      = SIMP(statut='o', typ='TXM', defaut='FX', into=('FX', 'FY', 'FZ', 'MX', 'MY', 'MZ', 'PRE')),
         TABLE     = SIMP(statut='o', typ=table_sdaster),
         TABLE_S   = SIMP(statut='f', typ=table_sdaster)),
      RESU_THER = FACT(statut='f', max='**',
         NUM_TRAN  = SIMP(statut='o', typ='I'),
         TABLE_T   = SIMP(statut='o', typ=table_sdaster),
         TABLE_TEMP= SIMP(statut='o', typ=table_sdaster),
         TABLE_S   = SIMP(statut='f', typ=table_sdaster),
         TABLE_ST  = SIMP(statut='f', typ=table_sdaster)),
         ),
   b_mef = BLOC(condition = """equal_to("TYPE_CALC", 'MEF') """,
      regles = (AU_MOINS_UN('RESU_MECA','RESU_THER')),
      DIAMETRE = SIMP(statut='o', typ='R'),
      ORIGINE  = SIMP(statut='o', typ='TXM', defaut='INTERNE', into=('INTERNE', 'EXTERNE')),
      COEF_U   = SIMP(statut='f', typ='R',   defaut=1.0),
      RESU_MECA = FACT(statut='f', max='**',
         AZI       = SIMP(statut='o', typ='R'),
         TABLE_T   = SIMP(statut='o', typ=table_sdaster),
         TABLE_F   = SIMP(statut='o', typ=table_sdaster),
         TABLE_P   = SIMP(statut='o', typ=table_sdaster),
         TABLE_CA  = SIMP(statut='o', typ=table_sdaster)),
      RESU_THER=FACT(statut='f', max='**',
         AZI       = SIMP(statut='o', typ='R'),
         NUM_CHAR  = SIMP(statut='o', typ='I'),
         TABLE_T   = SIMP(statut='o', typ=table_sdaster),
         TABLE_TI  = SIMP(statut='o', typ=table_sdaster)),
      ),
   b_tuyauterie = BLOC(condition = """equal_to("TYPE_CALC", 'TUYAUTERIE') """,
      RESU_MECA = FACT(statut='o', max='**',
         NUM_CHAR  = SIMP(statut='o', typ='I'),
         TABLE     = SIMP(statut='o', typ=table_sdaster),
         MAILLAGE  = SIMP(statut='o', typ=maillage_sdaster)),
         ),
   UNITE = SIMP(statut='f',typ=UnitType(),defaut=38, inout='out'),
   AJOUT = SIMP(statut='f', typ='TXM', defaut='NON', into=('OUI', 'NON')),
   );
