subroutine mrconl(oper, lmat, neq2, typev, rvect,&
                  nvect)
    implicit none
#include "jeveux.h"
#include "asterfort/assert.h"
#include "asterfort/jedema.h"
#include "asterfort/jeexin.h"
#include "asterfort/jelira.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
    integer :: lmat, neq2, nvect
    character(len=1) :: typev
    character(len=4) :: oper
    real(kind=8) :: rvect(*)
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
!     TENIR COMPTE DU CONDITIONNEMENT DES LAGRANGE SUR DES VECTEURS
!     ------------------------------------------------------------------
! IN  : OPER    : 'MULT' : ON MULTIPLIE RVECT PAR RCOEF
!                 'DIVI' : ON DIVISE RVECT PAR RCOEF
! IN  : LMAT    : ADRESSE DU DESCRIPTEUR DE LA MATRICE
! IN  : NEQ2    : NOMBRE D'EQUATIONS DU VECTEUR RVECT(NEQ2,NVECT)
!                 SI NEQ2.LE.0 ALORS NEQ2 = LMAT(2)
! IN  : NVECT   : NOMBRE DE VECTEURS DU VECTEUR RVECT(NEQ2,NVECT)
! IN  : TYPEV   : TYPE DES COEFFICIENTS DU VECTEUR
!               = 'R'  : A COEFFICIENTS REELS
!               = 'C'  : A COEFFICIENTS COMPLEXES
!               = ' '  : LES COEFFICIENTS DU VECTEURS SONT DU MEME TYPE
!                        QUE CEUX DE LA MATRICE.
! VAR :  RVECT  : VECTEUR A MODIFIER
!               REMARQUE : RVECT DOIT ETRE DU MEME TYPE QUE LA MATRICE
!                          SOIT REAL*8
!                          SOIT COMPLEX*16
!     ------------------------------------------------------------------
!
!
    character(len=1) :: ftype(2), type, typecn
    character(len=24) :: conl
    complex(kind=8) :: c8cst
    integer ::  ieq, ii, ind, iret, ive, jconl, neq
!     ------------------------------------------------------------------
    data ftype/'R','C'/
!     ------------------------------------------------------------------
!
    call jemarq()
    ASSERT(oper.eq.'MULT' .or. oper.eq.'DIVI')
    if (typev .eq. ' ') then
        type=ftype(zi(lmat+3))
    else
        type=typev
    endif
    neq=neq2
    if (neq2 .le. 0) neq=zi(lmat+2)
!
!
    conl=zk24(zi(lmat+1))(1:19)//'.CONL'
    call jeexin(conl, iret)
    if (iret .ne. 0) then
        call jelira(conl, 'TYPE', cval=typecn)
        call jeveuo(conl, 'L', jconl)
        jconl=jconl-1
!
!
        if (type .eq. 'R' .and. typecn .eq. 'R') then
            do 30 ive = 1, nvect
                ind=neq*(ive-1)
                if (oper .eq. 'MULT') then
                    do 10 ieq = 1, neq
                        rvect(ind+ieq)=rvect(ind+ieq)*zr(jconl+ieq)
10                  continue
                else
                    do 20 ieq = 1, neq
                        rvect(ind+ieq)=rvect(ind+ieq)/zr(jconl+ieq)
20                  continue
                endif
30          continue
!
!
        else if (type.eq.'C') then
            if (typecn .eq. 'R') then
                do 60 ive = 1, nvect
                    ind=neq*(ive-1)
                    if (oper .eq. 'MULT') then
                        do 40 ieq = 1, neq
                            ii=ind+2*ieq
                            rvect(ii-1)=rvect(ii-1)*zr(jconl+ieq)
                            rvect(ii)=rvect(ii)*zr(jconl+ieq)
40                      continue
                    else
                        do 50 ieq = 1, neq
                            ii=ind+2*ieq
                            rvect(ii-1)=rvect(ii-1)/zr(jconl+ieq)
                            rvect(ii)=rvect(ii)/zr(jconl+ieq)
50                      continue
                    endif
60              continue
!
            else if (typecn.eq.'C') then
                do 90 ive = 1, nvect
                    ind=neq*(ive-1)
                    if (oper .eq. 'MULT') then
                        do 70 ieq = 1, neq
                            ii=ind+2*ieq
                            c8cst=dcmplx(rvect(ii-1),rvect(ii))
                            c8cst=c8cst*zc(jconl+ieq)
                            rvect(ii-1)=dble(c8cst)
                            rvect(ii)=dimag(c8cst)
70                      continue
                    else
                        do 80 ieq = 1, neq
                            ii=ind+2*ieq
                            c8cst=dcmplx(rvect(ii-1),rvect(ii))
                            c8cst=c8cst/zc(jconl+ieq)
                            rvect(ii-1)=dble(c8cst)
                            rvect(ii)=dimag(c8cst)
80                      continue
                    endif
90              continue
            endif
        endif
    endif
    call jedema()
end subroutine
