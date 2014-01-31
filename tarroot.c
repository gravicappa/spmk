#include <stdio.h>
#include <string.h>

struct tarhdr {
  char name[100];
  char mode[8];
  char uid[8];
  char gid[8];
  char size[12];
  char mtime[12];
  char checksum[8];
  char typeflag[1];
  char linkname[100];
  char magic[6];
  char version[2];
  char uname[32];
  char gname[32];
  char devmajor[8];
  char devminor[8];
  char prefix[155];
  char pad[12];
};

unsigned int
read_oct(int n, char *s)
{
  int i, r = 0;
  for (i = 0; i < n && s[i]; ++i)
    r = (r << 3) | ((s[i] - '0') & 7);
  return r;
}

void
upd_cksum(char cksum[8], char buf[512])
{
  unsigned int i, ck = 0;
  for (i = 0; i < 512; ++i)
    ck += buf[i];
  snprintf(cksum, 7, "%06o", ck);
}

int
main()
{
  char buf[512];
  struct tarhdr *hdr;
  unsigned int n, end = 0, off = 0;

  do {
    n = fread(buf, 1, sizeof(buf), stdin);
    off += n;
    if (off > end) {
      hdr = (struct tarhdr *)buf;
      if (hdr->name[0]) {
        end = off + ((read_oct(sizeof(hdr->size), hdr->size) + 511) & ~511);
        memset(hdr->checksum, ' ', sizeof(hdr->checksum));
        memset(hdr->uid, '0', sizeof(hdr->uid) - 1);
        memset(hdr->gid, '0', sizeof(hdr->gid) - 1);
        memset(hdr->uname, 0, sizeof(hdr->uname));
        memset(hdr->gname, 0, sizeof(hdr->gname));
        snprintf(hdr->uname, sizeof(hdr->uname), "root");
        snprintf(hdr->gname, sizeof(hdr->gname), "root");
        upd_cksum(hdr->checksum, buf);
      }
    }
    fwrite(buf, 1, n, stdout);
  } while (n == sizeof(buf));
  return 0;
}
