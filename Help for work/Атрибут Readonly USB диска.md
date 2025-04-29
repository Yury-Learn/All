#windows #disk

```
diskpart
list disk
select disk 1
attributes disk
attributes disk clear readonly
clean 
convert gpt
convert mbr
```