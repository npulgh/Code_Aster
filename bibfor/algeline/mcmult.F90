subroutine mcmult(cumul, lmat, vect, xsol, nbvect,&
                  prepos)
    implicit none
#include "asterf_types.h"
#include "jeveux.h"
#include "asterfort/dismoi.h"
#include "asterfort/jedema.h"
#include "asterfort/jedetr.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/mcmmvc.h"
#include "asterfort/mcmmvr.h"
#include "asterfort/mtdsc2.h"
#include "asterfort/mtmchc.h"
#include "asterfort/utmess.h"
#include "asterfort/wkvect.h"
#include "asterfort/as_deallocate.h"
#include "asterfort/as_allocate.h"
    character(len=*) :: cumul
    integer :: lmat, nbvect
    complex(kind=8) :: vect(*), xsol(*)
    aster_logical :: prepos, prepo2
!     ------------------------------------------------------------------
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
!     ------------------------------------------------------------------
!     EFFECTUE LE PRODUIT D'UNE MATRICE PAR N VECTEURS COMPLEXES.
!     LE RESULTAT EST STOCKE DANS N VECTEURS COMPLEXES
!     ATTENTION:
!       - MATRICE SYMETRIQUE OU NON, REELLE OU COMPLEXE
!       - VECTEURS INPUT ET OUTPUT COMPLEXES ET DISTINCTS
!       - POUR LES DDLS ELIMINES PAR AFFE_CHAR_CINE, ON NE PEUT PAS
!         CALCULER XSOL. CES DDLS SONT MIS A ZERO.
!     ------------------------------------------------------------------
! IN  CUMUL  : K4 :
!              / 'ZERO' : XSOL =        MAT*VECT
!              / 'CUMU' : XSOL = XSOL + MAT*VECT
!
! IN  LMAT  : I : DESCRIPTEUR DE LA MATRICE
! IN  VECT  :R/C: VECTEURS A MULTIPLIER PAR LA MATRICE
! VAR XSOL  :R/C: VECTEUR(S) SOLUTION(S)
!               SI CUMUL = 'ZERO' ALORS XSOL EST EN MODE OUT
! IN  NBVECT: I : NOMBRE DE VECTEURS A MULTIPLIER (ET DONC DE SOLUTIONS)
!     ------------------------------------------------------------------
    character(len=3) :: kmpic
    character(len=19) :: matas
    integer :: jsmdi, jsmhc, neq
    complex(kind=8), pointer :: vectmp(:) => null()
    character(len=24), pointer :: refa(:) => null()
!
    call jemarq()
    prepo2=prepos
    matas=zk24(zi(lmat+1))(1:19)
    call jeveuo(matas//'.REFA', 'L', vk24=refa)
    if (refa(3) .eq. 'ELIMF') call mtmchc(matas, 'ELIML')
!
    call dismoi('MPI_COMPLET', matas, 'MATR_ASSE', repk=kmpic)
    if (kmpic .ne. 'OUI') then
        call utmess('F', 'CALCULEL6_54')
    endif
!
    call jeveuo(refa(2)(1:14)//'.SMOS.SMHC', 'L', jsmhc)
    neq=zi(lmat+2)
    AS_ALLOCATE(vc=vectmp, size=neq)
!
!
!     SELON REEL OU COMPLEXE :
    if (zi(lmat+3) .eq. 1) then
!
        call mtdsc2(zk24(zi(lmat+1)), 'SMDI', 'L', jsmdi)
        call mcmmvr(cumul, lmat, zi(jsmdi), zi4(jsmhc), neq,&
                    vect, xsol, nbvect, vectmp, prepo2)
!
    else if (zi(lmat+3) .eq. 2) then
!
!     MATRICE COMPLEXE
        call mtdsc2(zk24(zi(lmat+1)), 'SMDI', 'L', jsmdi)
        call mcmmvc(cumul, lmat, zi(jsmdi), zi4(jsmhc), neq,&
                    vect, xsol, nbvect, vectmp, prepo2)
!
    else
!
        call utmess('F', 'ALGELINE_66')
!
    endif
!
    AS_DEALLOCATE(vc=vectmp)
    call jedema()
end subroutine
