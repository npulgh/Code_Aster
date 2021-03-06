subroutine nmcoma(modelz, mate  , carele    , ds_constitutive, ds_algopara,&
                  lischa, numedd, numfix    , solveu         , comref     ,&
                  sddisc, sddyna, ds_print  , ds_measure     , numins     ,&
                  iterat, fonact, ds_contact, valinc         , solalg     ,&
                  veelem, meelem, measse    , veasse         , maprec     ,&
                  matass, faccvg, ldccvg    , sdnume)
!
use NonLin_Datastructure_type
!
implicit none
!
#include "asterf_types.h"
#include "asterfort/assert.h"
#include "asterfort/infdbg.h"
#include "asterfort/isfonc.h"
#include "asterfort/ndynlo.h"
#include "asterfort/nmaint.h"
#include "asterfort/nmchcc.h"
#include "asterfort/nmchex.h"
#include "asterfort/nmchoi.h"
#include "asterfort/nmchra.h"
#include "asterfort/nmchrm.h"
#include "asterfort/nmcmat.h"
#include "asterfort/nmfint.h"
#include "asterfort/nmimck.h"
#include "asterfort/nmmatr.h"
#include "asterfort/nmrenu.h"
#include "asterfort/nmrinc.h"
#include "asterfort/nmtime.h"
#include "asterfort/nmxmat.h"
#include "asterfort/preres.h"
#include "asterfort/mtdscr.h"
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
! THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
! IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
! THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
! (AT YOUR OPTION) ANY LATER VERSION.
!
! THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
! WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
! MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
! GENERAL PUBLIC LICENSE FOR MORE DETAILS.
!
! YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
! ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mickael.abbas at edf.fr
! aslint: disable=W1504
!
    type(NL_DS_AlgoPara), intent(in) :: ds_algopara
    integer :: fonact(*)
    character(len=*) :: modelz
    character(len=24) :: mate, carele
    type(NL_DS_Measure), intent(inout) :: ds_measure
    character(len=24) :: numedd, numfix
    type(NL_DS_Constitutive), intent(in) :: ds_constitutive
    character(len=19) :: sddisc, sddyna, lischa, solveu, sdnume
    character(len=24) :: comref
    type(NL_DS_Print), intent(inout) :: ds_print
    character(len=19) :: meelem(*), veelem(*)
    character(len=19) :: solalg(*), valinc(*)
    character(len=19) :: measse(*), veasse(*)
    integer :: numins, iterat, ibid
    type(NL_DS_Contact), intent(inout) :: ds_contact
    character(len=19) :: maprec, matass
    integer :: faccvg, ldccvg
!
! --------------------------------------------------------------------------------------------------
!
! ROUTINE MECA_NON_LINE (CALCUL - UTILITAIRE)
!
! CALCUL DE LA MATRICE GLOBALE EN CORRECTION
!
! --------------------------------------------------------------------------------------------------
!
! IN  MODELE : MODELE
! IN  NUMEDD : NUME_DDL (VARIABLE AU COURS DU CALCUL)
! IN  NUMFIX : NUME_DDL (FIXE AU COURS DU CALCUL)
! IN  MATE   : CHAMP MATERIAU
! IN  CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
! IN  COMREF : VARI_COM DE REFERENCE
! In  ds_constitutive  : datastructure for constitutive laws management
! IN  LISCHA : LISTE DES CHARGES
! IO  ds_contact       : datastructure for contact management
! IN  SDDYNA : SD POUR LA DYNAMIQUE
! In  ds_algopara      : datastructure for algorithm parameters
! IN  SOLVEU : SOLVEUR
! IN  SDDISC : SD DISCRETISATION TEMPORELLE
! IO  ds_print         : datastructure for printing parameters
! IO  ds_measure       : datastructure for measure and statistics management
! IN  NUMINS : NUMERO D'INSTANT
! IN  ITERAT : NUMERO D'ITERATION
! IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
! IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
! IN  VEASSE : VARIABLE CHAPEAU POUR NOM DES VECT_ASSE
! IN  MEASSE : VARIABLE CHAPEAU POUR NOM DES MATR_ASSE
! IN  MEELEM : VARIABLE CHAPEAU POUR NOM DES MATR_ELEM
! IN  MEELEM : VARIABLE CHAPEAU POUR NOM DES VECT_ELEM
! OUT LFINT  : .TRUE. SI FORCES INTERNES CALCULEES
! OUT MATASS : MATRICE DE RESOLUTION ASSEMBLEE
! OUT MAPREC : MATRICE DE RESOLUTION ASSEMBLEE - PRECONDITIONNEMENT
! OUT FACCVG : CODE RETOUR FACTORISATION MATRICE GLOBALE
!                -1 : PAS DE FACTORISATION
!                 0 : CAS DU FONCTIONNEMENT NORMAL
!                 1 : MATRICE SINGULIERE
!                 2 : ERREUR LORS DE LA FACTORISATION
!                 3 : ON NE SAIT PAS SI SINGULIERE
! OUT LDCCVG : CODE RETOUR DE L'INTEGRATION DU COMPORTEMENT
!                -1 : PAS D'INTEGRATION DU COMPORTEMENT
!                 0 : CAS DU FONCTIONNEMENT NORMAL
!                 1 : ECHEC DE L'INTEGRATION DE LA LDC
!                 2 : ERREUR SUR LA NON VERIF. DE CRITERES PHYSIQUES
!                 3 : SIZZ PAS NUL POUR C_PLAN DEBORST
!
! --------------------------------------------------------------------------------------------------
!
    aster_logical :: reasma, lcamor, l_diri_undead, l_rom
    aster_logical :: ldyna, lamor, l_neum_undead, lcrigi, lcfint, larigi
    character(len=16) :: metcor, metpre
    character(len=16) :: optrig, optamo
    character(len=19) :: vefint, cnfint
    character(len=24) :: modele
    aster_logical :: renume
    integer :: ifm, niv
    integer :: nb_matr
    character(len=6) :: list_matr_type(20)
    character(len=16) :: list_calc_opti(20), list_asse_opti(20)
    aster_logical :: list_l_asse(20), list_l_calc(20)
!
! --------------------------------------------------------------------------------------------------
!
    call infdbg('MECA_NON_LINE', ifm, niv)
    if (niv .ge. 2) then
        write (ifm,*) '<MECANONLINE> ...... CALCUL MATRICE'
    endif
!
! - Initializations
!
    nb_matr              = 0
    list_matr_type(1:20) = ' '
    modele = modelz
    faccvg = -1
    ldccvg = -1
    renume = .false.
    lcamor = .false.
    call nmchex(veelem, 'VEELEM', 'CNFINT', vefint)
    call nmchex(veasse, 'VEASSE', 'CNFINT', cnfint)
!
! - Active functionnalites
!
    ldyna         = ndynlo(sddyna,'DYNAMIQUE')
    lamor         = ndynlo(sddyna,'MAT_AMORT')
    l_rom         = isfonc(fonact,'ROM')
    l_neum_undead = isfonc(fonact,'NEUM_UNDEAD')
    l_diri_undead = isfonc(fonact,'DIRI_UNDEAD')
!
! --- RE-CREATION DU NUME_DDL OU PAS
!
    call nmrenu(modelz, fonact, lischa, ds_contact, numedd,&
                renume)
!
! --- CHOIX DE REASSEMBLAGE DE LA MATRICE GLOBALE
!
    call nmchrm('CORRECTION', ds_algopara, fonact, sddisc, sddyna,&
                numins, iterat, ds_contact, metpre, metcor,&
                reasma)
!
! --- CHOIX DE REASSEMBLAGE DE L'AMORTISSEMENT
!
    if (lamor) then
        call nmchra(sddyna, renume, optamo, lcamor)
    endif
!
! --- OPTION DE CALCUL POUR MERIMO
!
    call nmchoi('CORRECTION', sddyna, numins, fonact, metpre,&
                metcor, reasma, lcamor, optrig, lcrigi,&
                larigi, lcfint)
!
! --- CALCUL DES FORCES INTERNES
!
    if (lcfint) then
        call nmfint(modele, mate  , carele, comref    , ds_constitutive,&
                    fonact, iterat, sddyna, ds_measure, valinc         ,&
                    solalg, ldccvg, vefint)
    endif
!
! --- ERREUR SANS POSSIBILITE DE CONTINUER
!
    if (ldccvg .eq. 1) goto 999
!
! --- ASSEMBLAGE DES FORCES INTERNES
!
    if (lcfint) then
        lcfint = .false.
        call nmaint(numedd, fonact, ds_contact, veasse, vefint,&
                    cnfint, sdnume)
    endif
!
! --- CALCUL DES MATR_ELEM CONTACT/XFEM_CONTACT
!
    call nmchcc(fonact, nb_matr, list_matr_type, list_calc_opti, list_asse_opti,&
                list_l_asse, list_l_calc)
!
! - Update dualized matrix for non-linear Dirichlet boundary conditions (undead)
!
    if (l_neum_undead) then
        call nmcmat('MESUIV', ' ', ' ', .true._1,&
                    .false._1, nb_matr, list_matr_type, list_calc_opti, list_asse_opti,&
                    list_l_calc, list_l_asse)
    endif
!
! --- ASSEMBLAGE DES MATR-ELEM DE RIGIDITE
!
    if (larigi) then
        call nmcmat('MERIGI', optrig, ' ', .false._1,&
                    larigi, nb_matr, list_matr_type, list_calc_opti, list_asse_opti,&
                    list_l_calc, list_l_asse)
    endif
!
! --- CALCUL DES MATR-ELEM D'AMORTISSEMENT DE RAYLEIGH A CALCULER
! --- NECESSAIRE SI MATR_ELEM RIGIDITE CHANGE !
!
    if (lcamor) then
        call nmcmat('MEAMOR', optamo, ' ', .true._1,&
                    .true._1, nb_matr, list_matr_type, list_calc_opti, list_asse_opti,&
                    list_l_calc, list_l_asse)
    endif
!
! - Update dualized relations for non-linear Dirichlet boundary conditions (undead)
!
    if (l_diri_undead) then
        call nmcmat('MEDIRI', ' ', ' ', .true._1,&
                    .false._1, nb_matr, list_matr_type, list_calc_opti, list_asse_opti,&
                    list_l_calc, list_l_asse)
    endif
!
! --- RE-CREATION MATRICE MASSE SI NECESSAIRE (NOUVEAU NUME_DDL)
!
    if (renume) then
        if (ldyna) then
            call nmcmat('MEMASS', ' ', ' ', .false._1,&
                        .true._1, nb_matr, list_matr_type, list_calc_opti, list_asse_opti,&
                        list_l_calc, list_l_asse)
        endif
        if (.not.reasma) then
            ASSERT(.false.)
        endif
    endif
!
! --- CALCUL ET ASSEMBLAGE DES MATR_ELEM DE LA LISTE
!
    if (nb_matr .gt. 0) then
        call nmxmat(modelz        , mate       , carele     , ds_constitutive, sddisc        ,&
                    sddyna        , fonact     , numins     , iterat         , valinc        ,&
                    solalg        , lischa     , comref     , numedd         , numfix        ,&
                    ds_measure    , ds_algopara, nb_matr    , list_matr_type , list_calc_opti,&
                    list_asse_opti, list_l_calc, list_l_asse, lcfint         , meelem        ,&
                    measse        , veelem     , ldccvg     , ds_contact)
    endif
!
! --- ERREUR SANS POSSIBILITE DE CONTINUER
!
    if (ldccvg .eq. 1) goto 999
!
! --- CALCUL DE LA MATRICE ASSEMBLEE GLOBALE
!
    if (reasma) then
        call nmmatr('CORRECTION', fonact    , lischa, numedd, sddyna,&
                    numins      , ds_contact, meelem, measse, matass)
    endif
!
! - Set matrix type in convergence table
!
    if (reasma) then
        call nmimck(ds_print, 'MATR_ASSE', metcor, .true._1)
    else
        call nmimck(ds_print, 'MATR_ASSE', metcor, .false._1)
    endif
!
! --- FACTORISATION DE LA MATRICE ASSEMBLEE GLOBALE
!
    if (reasma) then
        call nmtime(ds_measure, 'Init', 'Factor')
        call nmtime(ds_measure, 'Launch', 'Factor')
        if (l_rom) then
            call mtdscr(matass)
        else
            call preres(solveu, 'V', faccvg, maprec, matass,&
                        ibid, -9999)
        endif
        call nmtime(ds_measure, 'Stop', 'Factor')
        call nmrinc(ds_measure, 'Factor')
    endif
!
999 continue
!
end subroutine
