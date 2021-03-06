subroutine nmprac(fonact, lischa, numedd, numfix    , solveu     ,&
                  sddyna, ds_measure, ds_contact, ds_algopara,&
                  meelem, measse, maprec, matass    , faccvg)
!
use NonLin_Datastructure_type
!
implicit none
!
#include "asterf_types.h"
#include "jeveux.h"
#include "asterfort/dismoi.h"
#include "asterfort/infdbg.h"
#include "asterfort/isfonc.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexnum.h"
#include "asterfort/mtdsc2.h"
#include "asterfort/nmassm.h"
#include "asterfort/nmchex.h"
#include "asterfort/nmmatr.h"
#include "asterfort/nmrinc.h"
#include "asterfort/nmtime.h"
#include "asterfort/preres.h"
#include "asterfort/utmess.h"
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
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
!
    integer :: fonact(*)
    character(len=19) :: sddyna, lischa
    type(NL_DS_Measure), intent(inout) :: ds_measure
    character(len=24) :: numedd, numfix
    character(len=19) :: solveu
    character(len=19) :: meelem(*), measse(*)
    type(NL_DS_Contact), intent(in) :: ds_contact
    character(len=19) :: maprec, matass
    integer :: faccvg
    type(NL_DS_AlgoPara), intent(in) :: ds_algopara
!
! ----------------------------------------------------------------------
!
! ROUTINE MECA_NON_LINE (CALCUL - UTILITAIRE)
!
! CALCUL DE LA MATRICE GLOBALE ACCELERATION INITIALE
!
! ----------------------------------------------------------------------
!
! IN  NUMEDD : NUME_DDL (VARIABLE AU COURS DU CALCUL)
! IN  NUMFIX : NUME_DDL (FIXE AU COURS DU CALCUL)
! IN  LISCHA : LISTE DES CHARGES
! In  ds_contact       : datastructure for contact management
! IO  ds_measure       : datastructure for measure and statistics management
! IN  SDDYNA : SD POUR LA DYNAMIQUE
! IN  SOLVEU : SOLVEUR
! IN  MEELEM : VARIABLE CHAPEAU POUR NOM DES MATR_ELEM
! IN  MEASSE : VARIABLE CHAPEAU POUR NOM DES MATR_ASSE
! In  ds_algopara      : datastructure for algorithm parameters
! OUT MATASS : MATRICE DE RESOLUTION ASSEMBLEE
! OUT MAPREC : MATRICE DE RESOLUTION ASSEMBLEE - PRECONDITIONNEMENT
! OUT FACCVG : CODE RETOUR (INDIQUE SI LA MATRICE EST SINGULIERE)
!                   O -> MATRICE INVERSIBLE
!                   1 -> MATRICE SINGULIERE
!                   2 -> MATRICE PRESQUE SINGULIERE
!                   3 -> ON NE SAIT PAS SI LA MATRICE EST SINGULIERE
!
! ----------------------------------------------------------------------
!
    aster_logical :: lctcc
    integer :: ieq, ibid, numins
    integer :: iadia, neq, lres, neql
    character(len=8) :: kmatd
    integer :: jvalm, zislv1, zislv3
    integer :: ifm, niv
    character(len=16) :: optass
    character(len=19) :: masse
    integer, pointer :: slvi(:) => null()
!
! ----------------------------------------------------------------------
!
    call jemarq()
    call infdbg('MECA_NON_LINE', ifm, niv)
!
! --- AFFICHAGE
!
    if (niv .ge. 2) then
        write (ifm,*) '<MECANONLINE> ...... CALCUL MATRICE'
    endif
!
! --- INITIALISATIONS
!
    faccvg = -1
    numins = 1
    call dismoi('NB_EQUA', numedd, 'NUME_DDL', repi=neq)
!
! --- FONCTIONNALITES ACTIVEES
!
    lctcc = isfonc(fonact,'CONT_CONTINU')
!
! --- DECOMPACTION DES VARIABLES CHAPEAUX
!
    call nmchex(measse, 'MEASSE', 'MEMASS', masse)
!
! --- ASSEMBLAGE DE LA MATRICE MASSE
!
    optass = 'AVEC_DIRICHLET'
    call nmassm(fonact, lischa, numedd, numfix, ds_algopara,&
                'MEMASS', optass, meelem, masse)
!
! --- CALCUL DE LA MATRICE ASSEMBLEE GLOBALE
!
    call nmmatr('ACCEL_INIT', fonact    , lischa, numedd, sddyna,&
                numins      , ds_contact, meelem, measse, matass)
!
! --- SI METHODE CONTINUE ON REMPLACE LES TERMES DIAGONAUX NULS PAR
! --- DES UNS POUR POUVOIR INVERSER LA MATRICE ASSEMBLE MATASS
!
    if (lctcc) then
        call mtdsc2(matass, 'SXDI', 'L', iadia)
        call dismoi('MATR_DISTR', matass, 'MATR_ASSE', repk=kmatd)
        if (kmatd .eq. 'OUI') then
            call jeveuo(matass//'.&INT', 'L', lres)
            neql = zi(lres+5)
        else
            neql = neq
        endif
        call jeveuo(jexnum(matass//'.VALM', 1), 'E', jvalm)
        do ieq = 1, neql
            if (zr(jvalm-1+zi(iadia-1+ieq)) .eq. 0.d0) then
                zr(jvalm-1+zi(iadia-1+ieq)) = 1.d0
            endif
        end do
    endif
!
! --- ON ACTIVE LA DETECTION DE SINGULARITE (NPREC=8)
! --- ON EVITE L'ARRET FATAL LORS DE L'INVERSION DE LA MATRICE
!
    call jeveuo(solveu//'.SLVI', 'E', vi=slvi)
    zislv1 = slvi(1)
    zislv3 = slvi(3)
    slvi(1) = 8
    slvi(3) = 2
!
! --- FACTORISATION DE LA MATRICE ASSEMBLEE GLOBALE
!
    call nmtime(ds_measure, 'Init'  , 'Factor')
    call nmtime(ds_measure, 'Launch', 'Factor')
    call preres(solveu, 'V', faccvg, maprec, matass,&
                ibid, -9999)
    call nmtime(ds_measure, 'Stop', 'Factor')
    call nmrinc(ds_measure, 'Factor')
!
! --- RETABLISSEMENT CODE
!
    slvi(1) = zislv1
    slvi(3) = zislv3
!
! --- LA MATRICE PEUT ETRE QUASI-SINGULIERE PAR EXEMPLE POUR LES DKT
!
    if (faccvg .eq. 1) then
        call utmess('A', 'MECANONLINE_78')
    endif
!
    call jedema()
!
end subroutine
