# docker image load
Description	Load an image from a tar archive or STDIN
Usage	docker image load [OPTIONS]
Aliases
docker load
Description
Load an image or repository from a tar archive (even if compressed with gzip, bzip2, xz or zstd) from a file or STDIN. It restores both images and tags.

Options
Option	Default	Description
-i, --input		Read from tar archive file, instead of STDIN
-q, --quiet		Suppress the load output
Examples

 docker image ls

REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
Load images from STDIN

 docker load < busybox.tar.gz

Loaded image: busybox:latest
 docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
busybox             latest              769b9341d937        7 weeks ago         2.489 MB
Load images from a file (--input)

 docker load --input fedora.tar

Loaded image: fedora:rawhide
Loaded image: fedora:20

 docker images

REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
busybox             latest              769b9341d937        7 weeks ago         2.489 MB
fedora              rawhide             0d20aec6529d        7 weeks ago         387 MB
fedora              20                  58394af37342        7 weeks ago         385.5 MB
fedora              heisenbug           58394af37342        7 weeks ago         385.5 MB
fedora              latest              58394af37342        7 weeks ago         385.5 MB



### Команда для вывода информации по контейнеру.
Можно использовать имя или id контейнера. 
 sudo docker logs -f --until=10s f62f09941aa1