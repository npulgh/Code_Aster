subroutine lc0054(fami, kpg, ksp, ndim, imate,&
                  compor, crit, instam, instap, epsm,&
                  deps, sigm, vim, option, angmas,&
                  sigp, vip, typmod, icomp,&
                  nvi, dsidep, codret)
! aslint: disable=W1504,W0104
    implicit none
#include "asterfort/nmtevp.h"
#include "asterfort/rccoma.h"
#include "asterfort/utmess.h"
    integer :: imate, ndim, kpg, ksp, codret
    real(kind=8) :: crit(*), angmas(3)
    real(kind=8) :: instam, instap
    integer :: icomp, nvi
    real(kind=8) :: epsm(6), deps(6)
    real(kind=8) :: sigm(6), sigp(6)
    real(kind=8) :: vim(*), vip(*)
    real(kind=8) :: dsidep(6, 6)
    character(len=16) :: compor(*), option
    character(len=8) :: typmod(*)
    character(len=*) :: fami
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
!
!.......................................................................
!
!     BUT: LOI DE COMPORTEMENT A ECROUISSAGE ISOTROPE DEPENDANT DE LA
!          VITESSE DE DEFORMATION
!
!          RELATIONS : 'VMIS_JOHN_COOK'
!
!       IN      FAMI    FAMILLE DE POINT DE GAUSS (RIGI,MASS,...)
!       IN      KPG,KSP NUMERO DU (SOUS)POINT DE GAUSS
!       IN      NDIM    DIMENSION DE L ESPACE (3D=3,2D=2,1D=1)
!               TYPMOD  TYPE DE MODELISATION
!               IMATE    ADRESSE DU MATERIAU CODE
!               COMPOR    COMPORTEMENT DE L ELEMENT
!                     COMPOR(1) = RELATION DE COMPORTEMENT (CHABOCHE...)
!                     COMPOR(2) = NB DE VARIABLES INTERNES
!                     COMPOR(3) = TYPE DE DEFORMATION (PETIT,JAUMANN...)
!               CRIT    CRITERES  LOCAUX
!                       CRIT(1) = NOMBRE D ITERATIONS MAXI A CONVERGENCE
!                                 (ITER_INTE_MAXI == ITECREL)
!                       CRIT(2) = TYPE DE JACOBIEN A T+DT
!                                 (TYPE_MATR_COMP == MACOMP)
!                                 0 = EN VITESSE     > SYMETRIQUE
!                                 1 = EN INCREMENTAL > NON-SYMETRIQUE
!                                 9 = methode IMPLEX
!                       CRIT(3) = VALEUR DE LA TOLERANCE DE CONVERGENCE
!                                 (RESI_INTE_RELA == RESCREL)
!                       CRIT(5) = NOMBRE D'INCREMENTS POUR LE
!                                 REDECOUPAGE LOCAL DU PAS DE TEMPS
!                                 (ITER_INTE_PAS == ITEDEC)
!                                 0 = PAS DE REDECOUPAGE
!                                 N = NOMBRE DE PALIERS
!               INSTAM   INSTANT T
!               INSTAP   INSTANT T+DT
!               EPSM   DEFORMATION TOTALE A T
!               DEPS   INCREMENT DE DEFORMATION TOTALE
!               SIGM    CONTRAINTE A T
!               VIM    VARIABLES INTERNES A T    + INDICATEUR ETAT T
!    ATTENTION  VIM    VARIABLES INTERNES A T MODIFIEES SI REDECOUPAGE
!               OPTION     OPTION DE CALCUL A FAIRE
!                             'RIGI_MECA_TANG'> DSIDEP(T)
!                             'FULL_MECA'     > DSIDEP(T+DT) , SIG(T+DT)
!                             'RAPH_MECA'     > SIG(T+DT)
!                             'RIGI_MECA_IMPLEX' > DSIDEP(T), SIGEXTR
!               ANGMAS
!       OUT     SIGP    CONTRAINTE A T+DT
!               VIP    VARIABLES INTERNES A T+DT + INDICATEUR ETAT T+DT
!               DSIDEP    MATRICE DE COMPORTEMENT TANGENT A T+DT OU T
!.......................................................................
!               CODRET
!
! person_in_charge: sebastien.fayolle at edf.fr
    character(len=16) :: mcmate
    integer :: iret
    real(kind=8) :: r8bid
!
    call rccoma(imate, 'ELAS', 1, mcmate, iret)
!
    if (mcmate .eq. 'ELAS') then
        call nmtevp(fami, kpg, ksp, ndim, typmod,&
                    imate, compor, crit, instam, instap,&
                    deps, sigm, vim, option, sigp,&
                    vip, dsidep, r8bid, r8bid, codret)
    else
        call utmess('F', 'ALGORITH6_88')
    endif
!
end subroutine
