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
# person_in_charge: natacha.bereux at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


POST_RELEVE_T=OPER(nom="POST_RELEVE_T",op=51,sd_prod=table_sdaster,reentrant='f',
            fr=tr("Extraire des valeurs de composantes de champs de grandeurs pour y effectuer des calculs (moyenne,invariants,..)"
               " ou pour les exprimer dans d'autres repères"),
            docu="U4.81.21",

         reuse=SIMP(statut='c', typ=CO),
         ACTION          =FACT(statut='o',max='**',
                               regles=(UN_PARMI('RESULTAT','CHAM_GD'),),

           OPERATION       =SIMP(statut='o',typ='TXM',into=("EXTRACTION","MOYENNE","MOYENNE_ARITH","EXTREMA"),
                                 validators=NoRepeat(), max=2),
           INTITULE        =SIMP(statut='o',typ='TXM'),

           CHAM_GD         =SIMP(statut='f',typ=(cham_no_sdaster,
                                                 cham_elem,),),
           RESULTAT        =SIMP(statut='f',typ=resultat_sdaster),

           b_extrac        =BLOC(condition = """exists("RESULTAT")""",fr=tr("extraction des résultats"),
                                 regles=(EXCLUS('TOUT_ORDRE','NUME_ORDRE','LIST_ORDRE','NUME_MODE','LIST_MODE',
                                                'INST','LIST_INST','FREQ','LIST_FREQ','NOEUD_CMP','NOM_CAS'), ),
             NOM_CHAM        =SIMP(statut='o',typ='TXM',validators=NoRepeat(),into=C_NOM_CHAM_INTO(),),
             TOUT_ORDRE      =SIMP(statut='f',typ='TXM',into=("OUI",) ),
             NUME_ORDRE      =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
             LIST_ORDRE      =SIMP(statut='f',typ=listis_sdaster),
             NUME_MODE       =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
             LIST_MODE       =SIMP(statut='f',typ=listis_sdaster),
             NOEUD_CMP       =SIMP(statut='f',typ='TXM',validators=NoRepeat(),max='**'),
             NOM_CAS         =SIMP(statut='f',typ='TXM',validators=NoRepeat(),max='**'),
             FREQ            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
             LIST_FREQ       =SIMP(statut='f',typ=listr8_sdaster),
             INST            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
             LIST_INST       =SIMP(statut='f',typ=listr8_sdaster),
             CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU",),),
             b_prec_rela=BLOC(condition="""(equal_to("CRITERE", 'RELATIF'))""",
                 PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
             b_prec_abso=BLOC(condition="""(equal_to("CRITERE", 'ABSOLU'))""",
                 PRECISION       =SIMP(statut='o',typ='R',),),
           ),

           b_extrema   =BLOC(condition="""equal_to('OPERATION', 'EXTREMA')""",
                             fr=tr("recherche de MIN MAX"),
                             regles=(EXCLUS('TOUT_CMP','NOM_CMP'),),
              TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
              GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
              MAILLE          =SIMP(statut='c',typ=ma  ,validators=NoRepeat(),max='**'),
              GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
              NOEUD           =SIMP(statut='c',typ=no  ,validators=NoRepeat(),max='**'),
              TOUT_CMP        =SIMP(statut='f',typ='TXM',into=("OUI",)),
              NOM_CMP         =SIMP(statut='f',typ='TXM',max='**'),
           ),

           b_MOYENNE_ARITH   =BLOC(condition="""is_in('OPERATION', 'MOYENNE_ARITH')""",
                             fr=tr("moyenne sur des groupes"),
                             regles=(EXCLUS('TOUT_CMP','NOM_CMP'),),
              TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
              GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
              MAILLE          =SIMP(statut='c',typ=ma  ,validators=NoRepeat(),max='**'),
              GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
              NOEUD           =SIMP(statut='c',typ=no  ,validators=NoRepeat(),max='**'),
              TOUT_CMP        =SIMP(statut='f',typ='TXM',into=("OUI",)),
              NOM_CMP         =SIMP(statut='f',typ='TXM',max='**'),
           ),

           b_autre   =BLOC(condition="""not is_in('OPERATION', ('EXTREMA', 'MOYENNE_ARITH'))""",
                           fr=tr("extraction et moyenne"),
                           regles=(AU_MOINS_UN('GROUP_NO','NOEUD'),
                                   UN_PARMI('TOUT_CMP','NOM_CMP','INVARIANT','ELEM_PRINCIPAUX','RESULTANTE'),
                                   PRESENT_PRESENT('TRAC_DIR','DIRECTION'),
                                   ENSEMBLE('MOMENT','POINT'),
                                   PRESENT_PRESENT('MOMENT','RESULTANTE'),
                                   PRESENT_ABSENT('TOUT_CMP','TRAC_DIR','TRAC_NOR'),
                                   EXCLUS('TRAC_DIR','TRAC_NOR'),
                                   PRESENT_PRESENT('ORIGINE','AXE_Z'),),

              TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
              GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
              MAILLE          =SIMP(statut='c',typ=ma  ,validators=NoRepeat(),max='**'),
              GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
              NOEUD           =SIMP(statut='c',typ=no  ,validators=NoRepeat(),max='**'),

              TOUT_CMP        =SIMP(statut='f',typ='TXM',into=("OUI",)),
              NOM_CMP         =SIMP(statut='f',typ='TXM',max='**'),
              INVARIANT       =SIMP(statut='f',typ='TXM',into=("OUI",)),
              ELEM_PRINCIPAUX =SIMP(statut='f',typ='TXM',into=("OUI",) ),
              RESULTANTE      =SIMP(statut='f',typ='TXM',max='**',into=("DX","DY","DZ")),

              MOMENT          =SIMP(statut='f',typ='TXM',max='**',into=("DRX","DRY","DRZ")),
              POINT           =SIMP(statut='f',typ='R',max='**'),

              REPERE          =SIMP(statut='f',typ='TXM',defaut="GLOBAL",
                                 into=("GLOBAL","LOCAL","POLAIRE","UTILISATEUR","CYLINDRIQUE"),),
              ANGL_NAUT       =SIMP(statut='f',typ='R',min=3,max=3),
              ORIGINE         =SIMP(statut='f',typ='R',min=3,max=3),
              AXE_Z           =SIMP(statut='f',typ='R',min=3,max=3),

              TRAC_NOR        =SIMP(statut='f',typ='TXM',into=("OUI",)),
              TRAC_DIR        =SIMP(statut='f',typ='TXM',into=("OUI",)),
              DIRECTION       =SIMP(statut='f',typ='R',max='**'),

              VECT_Y          =SIMP(statut='f',typ='R',max='**'),
              MOYE_NOEUD      =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON")),
           ),

           FORMAT_C        =SIMP(statut='f',typ='TXM',defaut="MODULE",into=("MODULE","REEL","IMAG")),

         ),
         INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2)),
         TITRE           =SIMP(statut='f',typ='TXM'),
)  ;
