subroutine te0358(option, nomte)
!
implicit none
!
#include "jeveux.h"
#include "asterfort/assert.h"
#include "asterfort/dfdm3d.h"
#include "asterfort/elrefe_info.h"
#include "asterfort/jevech.h"
#include "asterfort/meta_vpta_coef.h"
#include "asterfort/get_meta_phasis.h"
#include "asterfort/get_meta_id.h"
#include "asterfort/get_elas_para.h"
#include "asterfort/rcvarc.h"
#include "asterfort/tecach.h"
#include "asterfort/utmess.h"
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! aslint: disable=W0104
! person_in_charge: mickael.abbas at edf.fr
!
    character(len=16), intent(in) :: option
    character(len=16), intent(in) :: nomte
!
! --------------------------------------------------------------------------------------------------
!
! Elementary computation
!
! Elements: 3D
! Option: CHAR_MECA_META_Z
!
! --------------------------------------------------------------------------------------------------
!
    integer ::  i, k, lgpg, iret, ispg
    real(kind=8) :: sigmo
    character(len=4) :: fami
    integer :: j_compor
    character(len=16) :: type_phas, rela_comp, valk(2)
    integer :: j_mate, j_mater
    integer :: meta_id, nb_phasis
    real(kind=8) :: young, nu, deuxmu
    integer :: j_sigm
    integer :: nb_sigm, elas_id
    integer :: j_poids, j_vf, j_dfde, j_geom
    integer :: nno, ipg, npg, jtab(7)
    integer :: j_vectu
    integer :: j_vari
    real(kind=8) :: sig(6), sigdv(6)
    real(kind=8) :: dfdx(27), dfdy(27), dfdz(27), poids, kron(6)
    real(kind=8) :: coef, trans
    real(kind=8) :: zcold_curr
    real(kind=8) :: phas_prev(5), phas_curr(5), temp
    logical :: l_temp
!
    data kron  /1.d0,1.d0,1.d0,0.d0,0.d0,0.d0/
!
! --------------------------------------------------------------------------------------------------
!
    ispg = 1
    fami = 'RIGI'
!
! - Element reference
!
    call elrefe_info(fami=fami,nno=nno,&
                     npg=npg,jpoids=j_poids,jvf=j_vf,jdfde=j_dfde)
    call tecach('OOO', 'PVARIPR', 'L', iret, nval=7,&
                itab=jtab)
    lgpg  = max(jtab(6),1)*jtab(7)
!
! - Geometry
!
    call jevech('PGEOMER', 'L', j_geom)
!
! - Comportement
!
    call jevech('PCOMPOR', 'L', j_compor)
    rela_comp = zk16(j_compor)
!
! - Cannot evaluate command variables effect for Mfront behaviors
!
    if ((rela_comp.eq.'MFRONT').or.(rela_comp.eq.'AnisoLemaitre')&
        .or.(rela_comp(1:4).eq.'Meta')) then
        goto 99
    endif
!
! - Get type of phasis
!
    call get_meta_id(meta_id, nb_phasis)
    ASSERT(nb_phasis.le.5)
    if ((meta_id.eq.0).or.(rela_comp.eq.'META_LEMA_ANI')) then
        goto 99
    endif
!
! - Check type of phasis
!
    type_phas = zk16(j_compor+7)
    valk(1) = type_phas
    if (type_phas.eq.'ACIER') then
        if (meta_id.ne.1) then
            valk(2) = 'ZIRC'
            call utmess('F', 'COMPOR3_8', nk = 2, valk = valk)
        endif
    elseif (type_phas.eq.'ZIRC') then
        if (meta_id.ne.2) then
            valk(2) = 'ACIER'
            call utmess('F', 'COMPOR3_8', nk = 2, valk = valk)
        endif
    else
        ASSERT(.false.)
    endif
!
! - Stresses
!
    nb_sigm=6
    call jevech('PCONTMR', 'L', j_sigm)
!
! - Internal variables
!
    call jevech('PVARIPR', 'L', j_vari)
!
! - Material parameters
!
    call jevech('PMATERC', 'L', j_mate)
    j_mater = zi(j_mate)
!
! - Output vector
!
    call jevech('PVECTUR', 'E', j_vectu)
    do i = 1, nno
        zr(j_vectu+3*i-3) = 0.d0
        zr(j_vectu+3*i-2) = 0.d0
        zr(j_vectu+3*i-1) = 0.d0
    end do
!
    do ipg = 1, npg
        k=(ipg-1)*nno
!
! ----- Derived of shape functions
!
        call dfdm3d(nno, ipg, j_poids, j_dfde, zr(j_geom),&
                    poids, dfdx, dfdy, dfdz)
!
! ----- Get current temperature
!
        call rcvarc(' ', 'TEMP', '+', fami, ipg,&
                    1, temp, iret)
        l_temp  = iret.eq.0
!
! ----- Get phasis
!
        phas_prev(:) = 0.d0
        phas_curr(:) = 0.d0
        call get_meta_phasis(fami     , '-'      , ipg        , ispg, meta_id,&
                             nb_phasis, phas_prev)
        call get_meta_phasis(fami     , '+'      , ipg        , ispg, meta_id,&
                             nb_phasis, phas_curr, zcold_ = zcold_curr)
!
! ----- Get elastic parameters
!
        call get_elas_para(fami, j_mater , '+', ipg,&
                           ispg, elas_id,&
                           e  = young , nu = nu)
        ASSERT(elas_id.eq.1)
        deuxmu = young/(1.d0+nu)

!
! ----- Compute coefficients for second member
!
        call meta_vpta_coef(rela_comp, lgpg      , fami     , ipg      , j_mater  ,&
                            l_temp   , temp      , meta_id,   nb_phasis, phas_prev,&
                            phas_curr, zcold_curr, young    , deuxmu   , coef     ,&
                            trans)
!
! ----- Compute stresses
!
        sigmo = 0.d0
        do i = 1, 3
            sigmo = sigmo + zr(j_sigm+(ipg-1)*nb_sigm+i-1)
        end do
        sigmo = sigmo/3.d0
!
        do i = 1, nb_sigm
            sigdv(i) = zr(j_sigm+(ipg-1)*nb_sigm+i-1)-sigmo*kron(i)
            sig(i)   = coef*(1.5d0*trans*sigdv(i))
            sig(i)   = deuxmu*sig(i)
        end do
!
! ----- Second member
!
        do i = 1, nno
            zr(j_vectu+3*(i-1))   = zr(j_vectu+3*(i-1))   +&
                                    poids*(sig(1)*dfdx(i)+sig(4)*dfdy(i)+sig(5)*dfdz(i))
            zr(j_vectu+3*(i-1)+1) = zr(j_vectu+3*(i-1)+1) +&
                                    poids*(sig(2)*dfdy(i)+sig(4)*dfdx(i)+sig(6)*dfdz(i))
            zr(j_vectu+3*(i-1)+2) = zr(j_vectu+3*(i-1)+2) +&
                                    poids*(sig(3)*dfdz(i)+sig(5)*dfdx(i)+sig(6)*dfdy(i))
        end do
    end do
!
99  continue
end subroutine
