# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
# person_in_charge: nicolas.brie at edf.fr

def calc_modes_ops(self, TYPE_RESU, OPTION,
                         SOLVEUR_MODAL, SOLVEUR, VERI_MODE, INFO, TITRE, **args):
    """
       Macro-command CALC_MODES, main file
    """

    ier=0

    import aster
    from Noyau.N_utils import AsType
    from Modal.calc_modes_simult import calc_modes_simult
    from Modal.calc_modes_inv import calc_modes_inv
    from Modal.calc_modes_multi_bandes import calc_modes_multi_bandes
    from Modal.calc_modes_post import calc_modes_post


    # La macro compte pour 1 dans la numerotation des commandes
    self.set_icmd(1)

    self.DeclareOut('modes',self.sd)

    l_multi_bandes = False # logical indicating if the computation is performed
                           # for DYNAMICAL modes on several bands

    if (TYPE_RESU == 'DYNAMIQUE'):

        if (OPTION == 'BANDE'):
            if len(args['CALC_FREQ']['FREQ']) > 2:
                l_multi_bandes = True
                MATR_RIGI = args['MATR_RIGI']
                del args['MATR_RIGI']
                MATR_MASS = args['MATR_MASS']
                del args['MATR_MASS']
                CALC_FREQ = args['CALC_FREQ']
                del args['CALC_FREQ']
                print 'matr_rigi : ', MATR_RIGI
                # call the old MACRO_MODE_MECA macro-command
                # (modes computation over several frequency bands,
                # with optionnal parallelization of the bands)
                modes = calc_modes_multi_bandes(self, MATR_RIGI, MATR_MASS, CALC_FREQ, SOLVEUR_MODAL,
                                                      SOLVEUR, VERI_MODE, INFO, TITRE, **args)

    if not l_multi_bandes:
        if OPTION in ('PLUS_PETITE', 'PLUS_GRANDE', 'CENTRE', 'BANDE', 'TOUT'):
            # call the MODE_ITER_SIMULT command
            modes = calc_modes_simult(self, TYPE_RESU, OPTION, SOLVEUR_MODAL,
                                            SOLVEUR, VERI_MODE, INFO, TITRE, **args)

        elif OPTION in ('SEPARE', 'AJUSTE', 'PROCHE'):
            # call the MODE_ITER_INV command
            modes = calc_modes_inv(self, TYPE_RESU, OPTION, SOLVEUR_MODAL,
                                         SOLVEUR, VERI_MODE, INFO, TITRE, **args)


    ##################
    # post-traitements
    ##################
    if (TYPE_RESU == 'DYNAMIQUE'):

        lmatphys = False # logical indicating if the matrices are physical or not (generalized)
        nom_matrrigi = aster.getcolljev(modes.nom.ljust(19)+'.REFD')[1][2]
        matrrigi = self.get_concept(nom_matrrigi.strip())
        if AsType(matrrigi).__name__ == 'matr_asse_depl_r':
            lmatphys = True

        if lmatphys :
            norme_mode = None
            if args['NORM_MODE'] != None:
                norme_mode = args['NORM_MODE']
            filtre_mode = None
            if args['FILTRE_MODE'] != None:
                filtre_mode= args['FILTRE_MODE']
            impression = None
            if args['IMPRESSION'] != None:
                impression = args['IMPRESSION']
            if (norme_mode != None) or (filtre_mode != None) or (impression != None):
                modes = calc_modes_post(self, modes, lmatphys, norme_mode, filtre_mode, impression)


    return ier