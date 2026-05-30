package example;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestStreamHandler;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.attribute.PosixFilePermission;
import java.util.Comparator;
import java.util.List;
import java.util.Set;
import java.util.stream.Stream;

public final class TaskRootPermissionsHandler implements RequestStreamHandler {
    private static final Path TASK_ROOT = Path.of("/var/task");

    @Override
    public void handleRequest(InputStream input, OutputStream output, Context context) throws IOException {
        output.write(renderTree().getBytes(StandardCharsets.UTF_8));
    }

    private static String renderTree() throws IOException {
        StringBuilder builder = new StringBuilder();
        builder.append(permissions(TASK_ROOT))
                .append(' ')
                .append(TASK_ROOT)
                .append(System.lineSeparator());
        appendChildren(builder, TASK_ROOT, "");
        return builder.toString();
    }

    private static void appendChildren(StringBuilder builder, Path directory, String prefix) throws IOException {
        List<Path> children;
        try (Stream<Path> paths = Files.list(directory)) {
            children = paths
                    .sorted(Comparator.comparing(path -> path.getFileName().toString()))
                    .toList();
        }

        for (int i = 0; i < children.size(); i++) {
            Path child = children.get(i);
            boolean last = i == children.size() - 1;
            boolean directoryChild = Files.isDirectory(child);

            builder.append(prefix)
                    .append(last ? "`-- " : "|-- ")
                    .append(permissions(child))
                    .append(' ')
                    .append(child.getFileName())
                    .append(directoryChild ? "/" : "")
                    .append(System.lineSeparator());

            if (directoryChild) {
                appendChildren(builder, child, prefix + (last ? "    " : "|   "));
            }
        }
    }

    private static String permissions(Path path) throws IOException {
        Set<PosixFilePermission> permissions = Files.getPosixFilePermissions(path);
        StringBuilder builder = new StringBuilder(9);
        appendPermission(builder, permissions, PosixFilePermission.OWNER_READ, 'r');
        appendPermission(builder, permissions, PosixFilePermission.OWNER_WRITE, 'w');
        appendPermission(builder, permissions, PosixFilePermission.OWNER_EXECUTE, 'x');
        appendPermission(builder, permissions, PosixFilePermission.GROUP_READ, 'r');
        appendPermission(builder, permissions, PosixFilePermission.GROUP_WRITE, 'w');
        appendPermission(builder, permissions, PosixFilePermission.GROUP_EXECUTE, 'x');
        appendPermission(builder, permissions, PosixFilePermission.OTHERS_READ, 'r');
        appendPermission(builder, permissions, PosixFilePermission.OTHERS_WRITE, 'w');
        appendPermission(builder, permissions, PosixFilePermission.OTHERS_EXECUTE, 'x');
        return builder.toString();
    }

    private static void appendPermission(
            StringBuilder builder,
            Set<PosixFilePermission> permissions,
            PosixFilePermission permission,
            char value
    ) {
        builder.append(permissions.contains(permission) ? value : '-');
    }
}
