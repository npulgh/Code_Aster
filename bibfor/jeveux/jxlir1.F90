subroutine jxlir1(ic, caralu)
! person_in_charge: j-pierre.lefebvre at edf.fr
! ======================================================================
! COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! aslint: disable=W1303
! for the path name
    implicit none
#include "asterf_types.h"
#include "asterc/closdr.h"
#include "asterc/opendr.h"
#include "asterc/readdr.h"
#include "asterfort/codent.h"
#include "asterfort/get_jvbasename.h"
#include "asterfort/utmess.h"
    integer :: ic, caralu(*)
! ----------------------------------------------------------------------
! RELECTURE DU PREMIER ENREGISTREMENT D UNE BASE JEVEUX
!
! IN  IC    : CLASSE ASSOCIEE
! OUT CARALU: CARACTERISTIQUES DE LA BASE
! ----------------------------------------------------------------------
    integer :: n
!-----------------------------------------------------------------------
    integer :: ierr, k
!-----------------------------------------------------------------------
    parameter      ( n = 5 )
    character(len=2) :: dn2
    character(len=5) :: classe
    character(len=8) :: nomfic, kstout, kstini
    common /kficje/  classe    , nomfic(n) , kstout(n) , kstini(n) ,&
     &                 dn2(n)
    character(len=8) :: nombas
    common /kbasje/  nombas(n)
    character(len=128) :: repglo, repvol
    common /banvje/  repglo,repvol
    integer :: lrepgl, lrepvo
    common /balvje/  lrepgl,lrepvo
    integer :: lbis, lois, lols, lor8, loc8
    common /ienvje/  lbis , lois , lols , lor8 , loc8
!     ------------------------------------------------------------------
    integer :: npar, np2
    parameter ( npar = 12, np2 = npar+3 )
    integer :: tampon(np2), mode
    aster_logical :: lexist
    character(len=8) :: nom
    character(len=512) :: nom512, valk(2)
! DEB ------------------------------------------------------------------
    ierr = 0
    mode = 1
    if ( kstout(ic) == 'LIBERE' .and. kstini(ic) == 'POURSUIT' ) then
        mode = 0
    endif
    if ( kstini(ic) == 'DEBUT' ) then
        mode = 2
    endif
    nom = nomfic(ic)(1:4)//'.   '
    call get_jvbasename(nomfic(ic)(1:4), 1, nom512)
    inquire (file=nom512,exist=lexist)
    if (.not. lexist) then
        valk(1) = nombas(ic)
        valk(2) = nom512
        call utmess('F', 'JEVEUX_12', nk=2, valk=valk)
    endif
    call opendr(nom512, mode, ierr)
!
!   SUR CRAY L'APPEL A READDR EST EFFECTUE AVEC UNE LONGUEUR EN
!   ENTIER, A MODIFIER LORSQUE L'ON PASSERA AUX ROUTINES C
!
    call readdr(nom512, tampon, np2*lois, 1, ierr)
    if (ierr .ne. 0) then
        call utmess('F', 'JEVEUX_13', sk=nombas(ic))
    endif
    call closdr(nom512, ierr)
    if (ierr .ne. 0) then
        call utmess('F', 'JEVEUX_14', sk=nombas(ic))
    endif
    do k = 1, npar
        caralu(k) = tampon(k+3)
    end do
! FIN ------------------------------------------------------------------
end subroutine
