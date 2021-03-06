subroutine malin1(motfaz, chargz, iocc, indmot, lisnoz,&
                  lonlis)
    implicit none
#include "jeveux.h"
#include "asterc/getfac.h"
#include "asterfort/dismoi.h"
#include "asterfort/getvem.h"
#include "asterfort/getvtx.h"
#include "asterfort/jedema.h"
#include "asterfort/jedetr.h"
#include "asterfort/jelira.h"
#include "asterfort/jemarq.h"
#include "asterfort/jenonu.h"
#include "asterfort/jenuno.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexnom.h"
#include "asterfort/jexnum.h"
#include "asterfort/wkvect.h"
#include "asterfort/as_deallocate.h"
#include "asterfort/as_allocate.h"
!
    character(len=*) :: motfaz, chargz, lisnoz
! ----------------------------------------------------------------------
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
!
!     CREATION DU VECTEUR DE K8 DE NOM LISNOZ ET DE LONGUEUR
!     LONLIS.
!     CE VECTEUR CONTIENT LA LISTE DES NOMS DES NOEUDS DEFINIS
!     PAR LES MOTS-CLES : GROUP_MA OU MAILLE
!     APRES LE MOT-FACTEUR LIAISON_ELEM.
!     CETTE LISTE NE CONTIENT QU'UNE OCCURENCE DES NOEUDS.
!
! IN       : MOTFAZ : MOT-CLE FACTEUR 'LIAISON_ELEM'
! IN       : CHARGZ : NOM D'UNE SD CHARGE
! IN       : IOCC   : NUMERO D'OCCURENCE DU MOT-FACTEUR
! IN       : INDMOT : INDICE = 0 --> TRAITEMENT DES MOTS-CLES
!                                    'GROUP_MA' OU 'MAILLE'
!                            = 1 --> TRAITEMENT DES MOTS-CLES
!                                     'GROUP_MA_1' OU 'MAILLE_1'
!                            = 2 --> TRAITEMENT DES MOTS-CLES
!                                     'GROUP_MA_2' OU 'MAILLE_2
! OUT      : LISNOZ : NOM DE LA LISTE DES NOEUDS
! OUT      : LONLIS : LONGUEUR DE LA LISTE DES NOEUDS
! ----------------------------------------------------------------------
!
    character(len=8) :: charge
    character(len=8) :: noma, nomnoe, nomail
    character(len=16) :: momail, mogrma
    character(len=16) :: motfac
    character(len=24) :: noeuma, mailma, grmama, lisnoe
    integer :: iarg
! ----------------------------------------------------------------------
!
!-----------------------------------------------------------------------
    integer :: ibid, idim1, idim2, idimax, igr, ima
    integer :: in1, indlis, indmot, indnoe, ino, iocc, jdes
    integer :: jgro,    jlist, lonlis, m
    integer :: n1, n2, nbma, nbmail, ng, ngr, nliai
    integer :: nmai, numail
    character(len=24), pointer :: trav1(:) => null()
    character(len=8), pointer :: trav2(:) => null()
    integer, pointer :: trav3(:) => null()
!-----------------------------------------------------------------------
    call jemarq()
    charge = chargz
    motfac = motfaz
    lisnoe = lisnoz
!
    if (indmot .eq. 0) then
        momail = 'MAILLE'
        mogrma = 'GROUP_MA'
    else if (indmot.eq.1) then
        momail = 'MAILLE_1'
        mogrma = 'GROUP_MA_1'
    else if (indmot.eq.2) then
        momail = 'MAILLE_2'
        mogrma = 'GROUP_MA_2'
    endif
!
    call getfac(motfac, nliai)
    if (nliai .eq. 0) goto 999
!
    call dismoi('NOM_MAILLA', charge, 'CHARGE', repk=noma)
!
    noeuma = noma//'.NOMNOE'
    mailma = noma//'.NOMMAI'
    grmama = noma//'.GROUPEMA'
!
    idimax = 0
    idim1 = 0
    idim2 = 0
!
!     -- CALCUL DE IDIM1=NB_NOEUD/MAILLE*NB_MAILLE/GROUP_MA*NB_GROUP_MA
!        ET VERIFICATION DE L'APPARTENANCE DES GROUP_MA
!        AUX GROUP_MA DU MAILLAGE
!        -------------------------------------------------------
    call getvtx(motfac, mogrma, iocc=iocc, nbval=0, nbret=ng)
    if (ng .ne. 0) then
        ng = -ng
        AS_ALLOCATE(vk24=trav1, size=ng)
        call getvem(noma, 'GROUP_MA', motfac, mogrma, iocc,&
                    iarg, ng, trav1, ngr)
        do igr = 1, ngr
            call jeveuo(jexnom(grmama, trav1(igr)), 'L', jgro)
            call jelira(jexnom(grmama, trav1(igr)), 'LONUTI', nbmail)
            do m = 1, nbmail
                numail = zi(jgro-1+m)
                call jenuno(jexnum(mailma, numail), nomail)
                call jenonu(jexnom(noma//'.NOMMAI', nomail), ibid)
                call jelira(jexnum(noma//'.CONNEX', ibid), 'LONMAX', n1)
                idim1 = idim1 + n1
            end do
        end do
    endif
!
!     -- CALCUL DE IDIM2=NB_NOEUD/MAILLE*NB_MAILLE DE LISTE DE MAILLES
!        ET VERIFICATION DE L'APPARTENANCE DES MAILLES
!        AUX MAILLES DU MAILLAGE
!        -------------------------------------------------------
    call getvtx(motfac, momail, iocc=iocc, nbval=0, nbret=nbma)
    if (nbma .ne. 0) then
        nbma = -nbma
        AS_ALLOCATE(vk8=trav2, size=nbma)
        call getvem(noma, 'MAILLE', motfac, momail, iocc,&
                    iarg, nbma, trav2, nmai)
        do ima = 1, nmai
            call jenonu(jexnom(noma//'.NOMMAI', trav2(ima)), ibid)
            call jelira(jexnum(noma//'.CONNEX', ibid), 'LONMAX', n2)
            idim2 = idim2 + n2
        end do
    endif
!
!     -- IDIMAX = MAJORANT DE LA LONGUEUR DE LA LISTE DE NOEUDS
!    ----------------------------------------------------------
    idimax = idim1 + idim2
!
!     -- ALLOCATION DU TABLEAU DES NOMS DE NOEUDS
!    ----------------------------------------------
    call wkvect(lisnoe, 'V V K8', idimax, jlist)
!
    indnoe = 0
!
    call getvtx(motfac, mogrma, iocc=iocc, nbval=0, nbret=ng)
    if (ng .ne. 0) then
        ng = -ng
        call getvtx(motfac, mogrma, iocc=iocc, nbval=ng, vect=trav1,&
                    nbret=ngr)
        do igr = 1, ngr
            call jeveuo(jexnom(grmama, trav1(igr)), 'L', jgro)
            call jelira(jexnom(grmama, trav1(igr)), 'LONUTI', nbmail)
            do m = 1, nbmail
                numail = zi(jgro-1+m)
                call jenuno(jexnum(mailma, numail), nomail)
                call jenonu(jexnom(noma//'.NOMMAI', nomail), ibid)
                call jeveuo(jexnum(noma//'.CONNEX', ibid), 'L', jdes)
                call jelira(jexnum(noma//'.CONNEX', ibid), 'LONMAX', n1)
                do ino = 1, n1
                    call jenuno(jexnum(noeuma, zi(jdes+ino-1)), nomnoe)
                    indnoe = indnoe + 1
                    zk8(jlist+indnoe-1) = nomnoe
                end do
            end do
        end do
    endif
!
    call getvtx(motfac, momail, iocc=iocc, nbval=0, nbret=nbma)
    if (nbma .ne. 0) then
        nbma = -nbma
        call getvtx(motfac, momail, iocc=iocc, nbval=nbma, vect=trav2,&
                    nbret=nmai)
        do ima = 1, nmai
            call jenonu(jexnom(noma//'.NOMMAI', trav2(ima)), ibid)
            call jeveuo(jexnum(noma//'.CONNEX', ibid), 'L', jdes)
            call jenonu(jexnom(noma//'.NOMMAI', trav2(ima)), ibid)
            call jelira(jexnum(noma//'.CONNEX', ibid), 'LONMAX', n2)
            do ino = 1, n2
                call jenuno(jexnum(noeuma, zi(jdes+ino-1)), nomnoe)
                indnoe = indnoe + 1
                zk8(jlist+indnoe-1) = nomnoe
            end do
        end do
    endif
!
!     -- ELIMINATION DES REDONDANCES EVENTUELLES DES NOEUDS
!        DE LA LISTE
!    -------------------------------------------------------------
    AS_ALLOCATE(vi=trav3, size=idimax)
!
    do ino = 1, idimax
        do in1 = ino+1, idimax
            if (zk8(jlist+in1-1) .eq. zk8(jlist+ino-1)) then
                trav3(in1) = 1
            endif
        end do
    end do
!
    indlis = 0
!
    do ino = 1, idimax
        if (trav3(ino) .eq. 0) then
            indlis = indlis + 1
            zk8(jlist+indlis-1) = zk8(jlist+ino-1)
        endif
    end do
!
    lonlis = indlis
!
    AS_DEALLOCATE(vk24=trav1)
    AS_DEALLOCATE(vk8=trav2)
    AS_DEALLOCATE(vi=trav3)
!
999 continue
    call jedema()
end subroutine
